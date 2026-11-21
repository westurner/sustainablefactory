//! Exact catalogue and group-axiom verifier for all 80 crystallographic layer groups
//! (`L_1` through `L_80`, International Tables for Crystallography, Vol. E).
//!
//! Every operation is represented in the crystal-system Bravais basis (oblique,
//! rectangular, square, or hexagonal) as an exact integer `2 × 2` in-plane matrix,
//! an out-of-plane reflection sign `rz ∈ {-1, 1}`, and a half-integer in-plane
//! translation `(tu / 2, tv / 2)` modulo `ℤ² × {0}` (so `tu, tv ∈ {0, 1}`).
//!
//! Note: Crystallographic symmetry order and orbit multiplicity are purely geometric
//! group properties; they do not validate electronic transport, QAHE, or superconductivity.

use std::collections::{BTreeSet, VecDeque};

/// Exact layer-group affine operation modulo 2D lattice translations `ℤ² × {0}`.
#[derive(Clone, Copy, Debug, Eq, Ord, PartialEq, PartialOrd)]
pub struct LayerOp {
    pub a00: i8,
    pub a01: i8,
    pub a10: i8,
    pub a11: i8,
    pub rz: i8,
    /// In-plane u-translation in half-lattice units (`0` or `1`, representing `0` or `1/2`).
    pub tu: u8,
    /// In-plane v-translation in half-lattice units (`0` or `1`, representing `0` or `1/2`).
    pub tv: u8,
}

impl LayerOp {
    pub const fn new(a00: i8, a01: i8, a10: i8, a11: i8, rz: i8, tu: u8, tv: u8) -> Self {
        Self {
            a00,
            a01,
            a10,
            a11,
            rz,
            tu: tu & 1,
            tv: tv & 1,
        }
    }

    pub const fn identity() -> Self {
        Self::new(1, 0, 0, 1, 1, 0, 0)
    }

    /// Exact composition `(R1, t1) ∘ (R2, t2) = (R1 R2, R1 t2 + t1 mod 2)`.
    pub const fn compose(self, rhs: Self) -> Self {
        let a00 = self.a00 * rhs.a00 + self.a01 * rhs.a10;
        let a01 = self.a00 * rhs.a01 + self.a01 * rhs.a11;
        let a10 = self.a10 * rhs.a00 + self.a11 * rhs.a10;
        let a11 = self.a10 * rhs.a01 + self.a11 * rhs.a11;
        let rz = self.rz * rhs.rz;
        let tu = (self.a00 as i16 * rhs.tu as i16 + self.a01 as i16 * rhs.tv as i16 + self.tu as i16)
            .rem_euclid(2) as u8;
        let tv = (self.a10 as i16 * rhs.tu as i16 + self.a11 as i16 * rhs.tv as i16 + self.tv as i16)
            .rem_euclid(2) as u8;
        Self {
            a00,
            a01,
            a10,
            a11,
            rz,
            tu,
            tv,
        }
    }

    /// Apply this operation to fractional coordinates `(u, v, z)` modulo `1` in `(u, v)`.
    pub fn apply(self, u: f64, v: f64, z: f64) -> (f64, f64, f64) {
        let nu = (self.a00 as f64 * u + self.a01 as f64 * v + 0.5 * self.tu as f64).rem_euclid(1.0);
        let nv = (self.a10 as f64 * u + self.a11 as f64 * v + 0.5 * self.tv as f64).rem_euclid(1.0);
        let nz = self.rz as f64 * z;
        (nu, nv, nz)
    }

    /// Project onto the 2D wallpaper operation (forgetting `rz`).
    pub const fn wallpaper_projection(self) -> (i8, i8, i8, i8, u8, u8) {
        (self.a00, self.a01, self.a10, self.a11, self.tu, self.tv)
    }
}

/// Crystal-system family of a layer group.
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum CrystalSystem {
    TriclinicOblique,
    MonoclinicOblique,
    MonoclinicRectangular,
    OrthorhombicRectangular,
    TetragonalSquare,
    TrigonalHexagonal,
    Hexagonal,
}

impl CrystalSystem {
    pub const fn as_str(self) -> &'static str {
        match self {
            Self::TriclinicOblique => "triclinic/oblique",
            Self::MonoclinicOblique => "monoclinic/oblique",
            Self::MonoclinicRectangular => "monoclinic/rectangular",
            Self::OrthorhombicRectangular => "orthorhombic/rectangular",
            Self::TetragonalSquare => "tetragonal/square",
            Self::TrigonalHexagonal => "trigonal/hexagonal",
            Self::Hexagonal => "hexagonal",
        }
    }
}

/// Specification of one International Tables Vol. E layer group.
#[derive(Clone, Copy, Debug)]
pub struct LayerGroupSpec {
    pub number: u8,
    pub symbol: &'static str,
    pub crystal_system: CrystalSystem,
    pub wallpaper_projection: &'static str,
    /// Quotient order `|G / T_{Z^2}|` (counting centering translations in `c`-centered cells).
    pub expected_order: usize,
    pub generators: &'static [LayerOp],
}

/// Result of verifying the finite group axioms for a layer group.
#[derive(Clone, Debug, Eq, PartialEq)]
pub struct LayerGroupVerification {
    pub number: u8,
    pub symbol: String,
    pub crystal_system: String,
    pub wallpaper_projection: String,
    pub expected_order: usize,
    pub actual_order: usize,
    pub wallpaper_order: usize,
    pub has_identity: bool,
    pub closed_under_composition: bool,
    pub all_have_inverses: bool,
    pub order_matches: bool,
}

// Canonical generators
const ID: LayerOp = LayerOp::identity();
const INV: LayerOp = LayerOp::new(-1, 0, 0, -1, -1, 0, 0);
const C_CENT: LayerOp = LayerOp::new(1, 0, 0, 1, 1, 1, 1);

// Oblique / monoclinic c-axis
const C2Z: LayerOp = LayerOp::new(-1, 0, 0, -1, 1, 0, 0);
const MZ: LayerOp = LayerOp::new(1, 0, 0, 1, -1, 0, 0);
const AZ: LayerOp = LayerOp::new(1, 0, 0, 1, -1, 1, 0);
const BZ: LayerOp = LayerOp::new(1, 0, 0, 1, -1, 0, 1);
const NZ: LayerOp = LayerOp::new(1, 0, 0, 1, -1, 1, 1);

// Rectangular / orthorhombic
const C2X: LayerOp = LayerOp::new(1, 0, 0, -1, -1, 0, 0);
const S21X: LayerOp = LayerOp::new(1, 0, 0, -1, -1, 1, 0);
const C2Y: LayerOp = LayerOp::new(-1, 0, 0, 1, -1, 0, 0);
const S21Y: LayerOp = LayerOp::new(-1, 0, 0, 1, -1, 0, 1);
const MX: LayerOp = LayerOp::new(-1, 0, 0, 1, 1, 0, 0);
const BX: LayerOp = LayerOp::new(-1, 0, 0, 1, 1, 0, 1);
const MX_SHIFT: LayerOp = LayerOp::new(-1, 0, 0, 1, 1, 1, 0);
const BX_SHIFT: LayerOp = LayerOp::new(-1, 0, 0, 1, 1, 1, 1);
const MY: LayerOp = LayerOp::new(1, 0, 0, -1, 1, 0, 0);
const AY: LayerOp = LayerOp::new(1, 0, 0, -1, 1, 1, 0);
const AY_SHIFT: LayerOp = LayerOp::new(1, 0, 0, -1, 1, 1, 1);

// Tetragonal / square
const C4Z: LayerOp = LayerOp::new(0, -1, 1, 0, 1, 0, 0);
const S4Z: LayerOp = LayerOp::new(0, 1, -1, 0, -1, 0, 0);
const S21X_DIAG: LayerOp = LayerOp::new(1, 0, 0, -1, -1, 1, 1);

// Trigonal / hexagonal (in 120-degree lattice basis a1, a2)
const C3Z_HEX: LayerOp = LayerOp::new(0, -1, 1, -1, 1, 0, 0);
const C6Z_HEX: LayerOp = LayerOp::new(1, -1, 1, 0, 1, 0, 0);
const M110_HEX: LayerOp = LayerOp::new(0, 1, 1, 0, 1, 0, 0);   // mirror normal along 3rd pos (..m)
const M1M10_HEX: LayerOp = LayerOp::new(0, -1, -1, 0, 1, 0, 0); // mirror normal along 2nd pos (.m.)
const U2_POS2_HEX: LayerOp = LayerOp::new(0, 1, 1, 0, -1, 0, 0);   // 2-fold along 2nd pos (.2.)
const U2_POS3_HEX: LayerOp = LayerOp::new(0, -1, -1, 0, -1, 0, 0); // 2-fold along 3rd pos (..2)

/// Authoritative table of all 80 crystallographic layer groups (`L_1..L_80`, IT Vol. E).
pub const ALL_80_LAYER_GROUPS: [LayerGroupSpec; 80] = [
    // Triclinic / oblique (1-2)
    LayerGroupSpec { number: 1, symbol: "p1", crystal_system: CrystalSystem::TriclinicOblique, wallpaper_projection: "p1", expected_order: 1, generators: &[ID] },
    LayerGroupSpec { number: 2, symbol: "p-1", crystal_system: CrystalSystem::TriclinicOblique, wallpaper_projection: "p2", expected_order: 2, generators: &[INV] },

    // Monoclinic / oblique, unique axis c (3-7)
    LayerGroupSpec { number: 3, symbol: "p112", crystal_system: CrystalSystem::MonoclinicOblique, wallpaper_projection: "p2", expected_order: 2, generators: &[C2Z] },
    LayerGroupSpec { number: 4, symbol: "p11m", crystal_system: CrystalSystem::MonoclinicOblique, wallpaper_projection: "p1", expected_order: 2, generators: &[MZ] },
    LayerGroupSpec { number: 5, symbol: "p11a", crystal_system: CrystalSystem::MonoclinicOblique, wallpaper_projection: "p1", expected_order: 2, generators: &[AZ] },
    LayerGroupSpec { number: 6, symbol: "p112/m", crystal_system: CrystalSystem::MonoclinicOblique, wallpaper_projection: "p2", expected_order: 4, generators: &[C2Z, MZ] },
    LayerGroupSpec { number: 7, symbol: "p112/a", crystal_system: CrystalSystem::MonoclinicOblique, wallpaper_projection: "p2", expected_order: 4, generators: &[C2Z, AZ] },

    // Monoclinic / rectangular, unique axis a (8-18)
    LayerGroupSpec { number: 8, symbol: "p211", crystal_system: CrystalSystem::MonoclinicRectangular, wallpaper_projection: "pm", expected_order: 2, generators: &[C2X] },
    LayerGroupSpec { number: 9, symbol: "p2_111", crystal_system: CrystalSystem::MonoclinicRectangular, wallpaper_projection: "pg", expected_order: 2, generators: &[S21X] },
    LayerGroupSpec { number: 10, symbol: "c211", crystal_system: CrystalSystem::MonoclinicRectangular, wallpaper_projection: "cm", expected_order: 4, generators: &[C_CENT, C2X] },
    LayerGroupSpec { number: 11, symbol: "pm11", crystal_system: CrystalSystem::MonoclinicRectangular, wallpaper_projection: "pm", expected_order: 2, generators: &[MX] },
    LayerGroupSpec { number: 12, symbol: "pb11", crystal_system: CrystalSystem::MonoclinicRectangular, wallpaper_projection: "pg", expected_order: 2, generators: &[BX] },
    LayerGroupSpec { number: 13, symbol: "cm11", crystal_system: CrystalSystem::MonoclinicRectangular, wallpaper_projection: "cm", expected_order: 4, generators: &[C_CENT, MX] },
    LayerGroupSpec { number: 14, symbol: "p2/m11", crystal_system: CrystalSystem::MonoclinicRectangular, wallpaper_projection: "p2mm", expected_order: 4, generators: &[C2X, MX] },
    LayerGroupSpec { number: 15, symbol: "p2_1/m11", crystal_system: CrystalSystem::MonoclinicRectangular, wallpaper_projection: "p2mg", expected_order: 4, generators: &[S21X, MX] },
    LayerGroupSpec { number: 16, symbol: "p2/b11", crystal_system: CrystalSystem::MonoclinicRectangular, wallpaper_projection: "p2mg", expected_order: 4, generators: &[C2X, BX] },
    LayerGroupSpec { number: 17, symbol: "p2_1/b11", crystal_system: CrystalSystem::MonoclinicRectangular, wallpaper_projection: "p2gg", expected_order: 4, generators: &[S21X, BX] },
    LayerGroupSpec { number: 18, symbol: "c2/m11", crystal_system: CrystalSystem::MonoclinicRectangular, wallpaper_projection: "c2mm", expected_order: 8, generators: &[C_CENT, C2X, MX] },

    // Orthorhombic / rectangular: class 222 (19-22)
    LayerGroupSpec { number: 19, symbol: "p222", crystal_system: CrystalSystem::OrthorhombicRectangular, wallpaper_projection: "p2mm", expected_order: 4, generators: &[C2X, C2Y] },
    LayerGroupSpec { number: 20, symbol: "p2_122", crystal_system: CrystalSystem::OrthorhombicRectangular, wallpaper_projection: "p2mg", expected_order: 4, generators: &[S21X, C2Y] },
    LayerGroupSpec { number: 21, symbol: "p2_12_12", crystal_system: CrystalSystem::OrthorhombicRectangular, wallpaper_projection: "p2gg", expected_order: 4, generators: &[S21X, S21Y] },
    LayerGroupSpec { number: 22, symbol: "c222", crystal_system: CrystalSystem::OrthorhombicRectangular, wallpaper_projection: "c2mm", expected_order: 8, generators: &[C_CENT, C2X, C2Y] },

    // Orthorhombic / rectangular: class mm2 (23-26)
    LayerGroupSpec { number: 23, symbol: "pmm2", crystal_system: CrystalSystem::OrthorhombicRectangular, wallpaper_projection: "p2mm", expected_order: 4, generators: &[MX, MY] },
    LayerGroupSpec { number: 24, symbol: "pma2", crystal_system: CrystalSystem::OrthorhombicRectangular, wallpaper_projection: "p2mg", expected_order: 4, generators: &[MX_SHIFT, AY] },
    LayerGroupSpec { number: 25, symbol: "pba2", crystal_system: CrystalSystem::OrthorhombicRectangular, wallpaper_projection: "p2gg", expected_order: 4, generators: &[BX_SHIFT, AY_SHIFT] },
    LayerGroupSpec { number: 26, symbol: "cmm2", crystal_system: CrystalSystem::OrthorhombicRectangular, wallpaper_projection: "c2mm", expected_order: 8, generators: &[C_CENT, MX, MY] },

    // Orthorhombic / rectangular: class m2m (27-36)
    LayerGroupSpec { number: 27, symbol: "pm2m", crystal_system: CrystalSystem::OrthorhombicRectangular, wallpaper_projection: "pm", expected_order: 4, generators: &[MX, MZ] },
    LayerGroupSpec { number: 28, symbol: "pm2_1b", crystal_system: CrystalSystem::OrthorhombicRectangular, wallpaper_projection: "pm", expected_order: 4, generators: &[MX, BZ] },
    LayerGroupSpec { number: 29, symbol: "pb2_1m", crystal_system: CrystalSystem::OrthorhombicRectangular, wallpaper_projection: "pg", expected_order: 4, generators: &[BX, MZ] },
    LayerGroupSpec { number: 30, symbol: "pb2b", crystal_system: CrystalSystem::OrthorhombicRectangular, wallpaper_projection: "pg", expected_order: 4, generators: &[BX, BZ] },
    LayerGroupSpec { number: 31, symbol: "pm2a", crystal_system: CrystalSystem::OrthorhombicRectangular, wallpaper_projection: "pm", expected_order: 4, generators: &[MX, AZ] },
    LayerGroupSpec { number: 32, symbol: "pm2_1n", crystal_system: CrystalSystem::OrthorhombicRectangular, wallpaper_projection: "pm", expected_order: 4, generators: &[MX, NZ] },
    LayerGroupSpec { number: 33, symbol: "pb2_1a", crystal_system: CrystalSystem::OrthorhombicRectangular, wallpaper_projection: "pg", expected_order: 4, generators: &[BX, AZ] },
    LayerGroupSpec { number: 34, symbol: "pb2n", crystal_system: CrystalSystem::OrthorhombicRectangular, wallpaper_projection: "pg", expected_order: 4, generators: &[BX, NZ] },
    LayerGroupSpec { number: 35, symbol: "cm2m", crystal_system: CrystalSystem::OrthorhombicRectangular, wallpaper_projection: "cm", expected_order: 8, generators: &[C_CENT, MX, MZ] },
    LayerGroupSpec { number: 36, symbol: "cm2e", crystal_system: CrystalSystem::OrthorhombicRectangular, wallpaper_projection: "cm", expected_order: 8, generators: &[C_CENT, MX, AZ] },

    // Orthorhombic / rectangular: class mmm (37-48)
    LayerGroupSpec { number: 37, symbol: "pmmm", crystal_system: CrystalSystem::OrthorhombicRectangular, wallpaper_projection: "p2mm", expected_order: 8, generators: &[MX, MY, MZ] },
    LayerGroupSpec { number: 38, symbol: "pmaa", crystal_system: CrystalSystem::OrthorhombicRectangular, wallpaper_projection: "p2mg", expected_order: 8, generators: &[MX_SHIFT, AY, AZ] },
    LayerGroupSpec { number: 39, symbol: "pban", crystal_system: CrystalSystem::OrthorhombicRectangular, wallpaper_projection: "p2gg", expected_order: 8, generators: &[BX_SHIFT, AY_SHIFT, NZ] },
    LayerGroupSpec { number: 40, symbol: "pmam", crystal_system: CrystalSystem::OrthorhombicRectangular, wallpaper_projection: "p2mg", expected_order: 8, generators: &[MX_SHIFT, AY, MZ] },
    LayerGroupSpec { number: 41, symbol: "pmma", crystal_system: CrystalSystem::OrthorhombicRectangular, wallpaper_projection: "p2mm", expected_order: 8, generators: &[MX, MY, AZ] },
    LayerGroupSpec { number: 42, symbol: "pman", crystal_system: CrystalSystem::OrthorhombicRectangular, wallpaper_projection: "p2mg", expected_order: 8, generators: &[MX_SHIFT, AY, NZ] },
    LayerGroupSpec { number: 43, symbol: "pbaa", crystal_system: CrystalSystem::OrthorhombicRectangular, wallpaper_projection: "p2gg", expected_order: 8, generators: &[BX_SHIFT, AY_SHIFT, AZ] },
    LayerGroupSpec { number: 44, symbol: "pbam", crystal_system: CrystalSystem::OrthorhombicRectangular, wallpaper_projection: "p2gg", expected_order: 8, generators: &[BX_SHIFT, AY_SHIFT, MZ] },
    LayerGroupSpec { number: 45, symbol: "pbma", crystal_system: CrystalSystem::OrthorhombicRectangular, wallpaper_projection: "p2mg", expected_order: 8, generators: &[BX, MY, AZ] },
    LayerGroupSpec { number: 46, symbol: "pmmn", crystal_system: CrystalSystem::OrthorhombicRectangular, wallpaper_projection: "p2mm", expected_order: 8, generators: &[MX, MY, NZ] },
    LayerGroupSpec { number: 47, symbol: "cmmm", crystal_system: CrystalSystem::OrthorhombicRectangular, wallpaper_projection: "c2mm", expected_order: 16, generators: &[C_CENT, MX, MY, MZ] },
    LayerGroupSpec { number: 48, symbol: "cmme", crystal_system: CrystalSystem::OrthorhombicRectangular, wallpaper_projection: "c2mm", expected_order: 16, generators: &[C_CENT, MX, MY, AZ] },

    // Tetragonal / square (49-64)
    LayerGroupSpec { number: 49, symbol: "p4", crystal_system: CrystalSystem::TetragonalSquare, wallpaper_projection: "p4", expected_order: 4, generators: &[C4Z] },
    LayerGroupSpec { number: 50, symbol: "p-4", crystal_system: CrystalSystem::TetragonalSquare, wallpaper_projection: "p4", expected_order: 4, generators: &[S4Z] },
    LayerGroupSpec { number: 51, symbol: "p4/m", crystal_system: CrystalSystem::TetragonalSquare, wallpaper_projection: "p4", expected_order: 8, generators: &[C4Z, MZ] },
    LayerGroupSpec { number: 52, symbol: "p4/n", crystal_system: CrystalSystem::TetragonalSquare, wallpaper_projection: "p4", expected_order: 8, generators: &[C4Z, NZ] },
    LayerGroupSpec { number: 53, symbol: "p422", crystal_system: CrystalSystem::TetragonalSquare, wallpaper_projection: "p4mm", expected_order: 8, generators: &[C4Z, C2X] },
    LayerGroupSpec { number: 54, symbol: "p42_12", crystal_system: CrystalSystem::TetragonalSquare, wallpaper_projection: "p4gm", expected_order: 8, generators: &[C4Z, S21X_DIAG] },
    LayerGroupSpec { number: 55, symbol: "p4mm", crystal_system: CrystalSystem::TetragonalSquare, wallpaper_projection: "p4mm", expected_order: 8, generators: &[C4Z, MX] },
    LayerGroupSpec { number: 56, symbol: "p4bm", crystal_system: CrystalSystem::TetragonalSquare, wallpaper_projection: "p4gm", expected_order: 8, generators: &[C4Z, BX_SHIFT] },
    LayerGroupSpec { number: 57, symbol: "p-42m", crystal_system: CrystalSystem::TetragonalSquare, wallpaper_projection: "p4mm", expected_order: 8, generators: &[S4Z, C2X] },
    LayerGroupSpec { number: 58, symbol: "p-42_1m", crystal_system: CrystalSystem::TetragonalSquare, wallpaper_projection: "p4gm", expected_order: 8, generators: &[S4Z, S21X_DIAG] },
    LayerGroupSpec { number: 59, symbol: "p-4m2", crystal_system: CrystalSystem::TetragonalSquare, wallpaper_projection: "p4mm", expected_order: 8, generators: &[S4Z, MX] },
    LayerGroupSpec { number: 60, symbol: "p-4b2", crystal_system: CrystalSystem::TetragonalSquare, wallpaper_projection: "p4gm", expected_order: 8, generators: &[S4Z, BX_SHIFT] },
    LayerGroupSpec { number: 61, symbol: "p4/mmm", crystal_system: CrystalSystem::TetragonalSquare, wallpaper_projection: "p4mm", expected_order: 16, generators: &[C4Z, MX, MZ] },
    LayerGroupSpec { number: 62, symbol: "p4/nbm", crystal_system: CrystalSystem::TetragonalSquare, wallpaper_projection: "p4gm", expected_order: 16, generators: &[C4Z, BX_SHIFT, NZ] },
    LayerGroupSpec { number: 63, symbol: "p4/mbm", crystal_system: CrystalSystem::TetragonalSquare, wallpaper_projection: "p4gm", expected_order: 16, generators: &[C4Z, BX_SHIFT, MZ] },
    LayerGroupSpec { number: 64, symbol: "p4/nmm", crystal_system: CrystalSystem::TetragonalSquare, wallpaper_projection: "p4mm", expected_order: 16, generators: &[C4Z, MX, NZ] },

    // Trigonal / hexagonal (65-72)
    LayerGroupSpec { number: 65, symbol: "p3", crystal_system: CrystalSystem::TrigonalHexagonal, wallpaper_projection: "p3", expected_order: 3, generators: &[C3Z_HEX] },
    LayerGroupSpec { number: 66, symbol: "p-3", crystal_system: CrystalSystem::TrigonalHexagonal, wallpaper_projection: "p6", expected_order: 6, generators: &[C3Z_HEX, INV] },
    LayerGroupSpec { number: 67, symbol: "p312", crystal_system: CrystalSystem::TrigonalHexagonal, wallpaper_projection: "p31m", expected_order: 6, generators: &[C3Z_HEX, U2_POS3_HEX] },
    LayerGroupSpec { number: 68, symbol: "p321", crystal_system: CrystalSystem::TrigonalHexagonal, wallpaper_projection: "p3m1", expected_order: 6, generators: &[C3Z_HEX, U2_POS2_HEX] },
    LayerGroupSpec { number: 69, symbol: "p3m1", crystal_system: CrystalSystem::TrigonalHexagonal, wallpaper_projection: "p3m1", expected_order: 6, generators: &[C3Z_HEX, M1M10_HEX] },
    LayerGroupSpec { number: 70, symbol: "p31m", crystal_system: CrystalSystem::TrigonalHexagonal, wallpaper_projection: "p31m", expected_order: 6, generators: &[C3Z_HEX, M110_HEX] },
    LayerGroupSpec { number: 71, symbol: "p-31m", crystal_system: CrystalSystem::TrigonalHexagonal, wallpaper_projection: "p6mm", expected_order: 12, generators: &[C3Z_HEX, INV, M110_HEX] },
    LayerGroupSpec { number: 72, symbol: "p-3m1", crystal_system: CrystalSystem::TrigonalHexagonal, wallpaper_projection: "p6mm", expected_order: 12, generators: &[C3Z_HEX, INV, M1M10_HEX] },

    // Hexagonal (73-80)
    LayerGroupSpec { number: 73, symbol: "p6", crystal_system: CrystalSystem::Hexagonal, wallpaper_projection: "p6", expected_order: 6, generators: &[C6Z_HEX] },
    LayerGroupSpec { number: 74, symbol: "p-6", crystal_system: CrystalSystem::Hexagonal, wallpaper_projection: "p3", expected_order: 6, generators: &[C3Z_HEX, MZ] },
    LayerGroupSpec { number: 75, symbol: "p6/m", crystal_system: CrystalSystem::Hexagonal, wallpaper_projection: "p6", expected_order: 12, generators: &[C6Z_HEX, MZ] },
    LayerGroupSpec { number: 76, symbol: "p622", crystal_system: CrystalSystem::Hexagonal, wallpaper_projection: "p6mm", expected_order: 12, generators: &[C6Z_HEX, U2_POS2_HEX] },
    LayerGroupSpec { number: 77, symbol: "p6mm", crystal_system: CrystalSystem::Hexagonal, wallpaper_projection: "p6mm", expected_order: 12, generators: &[C6Z_HEX, M110_HEX] },
    LayerGroupSpec { number: 78, symbol: "p-6m2", crystal_system: CrystalSystem::Hexagonal, wallpaper_projection: "p3m1", expected_order: 12, generators: &[C3Z_HEX, MZ, M1M10_HEX] },
    LayerGroupSpec { number: 79, symbol: "p-62m", crystal_system: CrystalSystem::Hexagonal, wallpaper_projection: "p31m", expected_order: 12, generators: &[C3Z_HEX, MZ, M110_HEX] },
    LayerGroupSpec { number: 80, symbol: "p6/mmm", crystal_system: CrystalSystem::Hexagonal, wallpaper_projection: "p6mm", expected_order: 24, generators: &[C6Z_HEX, MZ, M110_HEX] },
];

/// Generate the full finite quotient group `G / T_{Z^2}` from a set of exact generators.
pub fn generate_group_elements(generators: &[LayerOp]) -> BTreeSet<LayerOp> {
    let mut elements = BTreeSet::new();
    let mut queue = VecDeque::new();
    elements.insert(LayerOp::identity());
    queue.push_back(LayerOp::identity());
    for &generator in generators {
        if elements.insert(generator) {
            queue.push_back(generator);
        }
    }
    while let Some(current) = queue.pop_front() {
        for &generator in generators {
            let next_r = current.compose(generator);
            if elements.insert(next_r) {
                queue.push_back(next_r);
            }
            let next_l = generator.compose(current);
            if elements.insert(next_l) {
                queue.push_back(next_l);
            }
        }
    }
    elements
}

/// Look up an International Tables Vol. E layer group by number `1..=80`.
pub fn get_layer_group(number: u8) -> Option<&'static LayerGroupSpec> {
    if (1..=80).contains(&number) {
        Some(&ALL_80_LAYER_GROUPS[(number - 1) as usize])
    } else {
        None
    }
}

/// Verify all finite group axioms (identity, closure, inverses, exact order) for layer group `number`.
pub fn verify_layer_group(number: u8) -> Option<LayerGroupVerification> {
    let spec = get_layer_group(number)?;
    let elements = generate_group_elements(spec.generators);
    let id = LayerOp::identity();
    let has_identity = elements.contains(&id);

    let mut closed = true;
    for &g in &elements {
        for &h in &elements {
            if !elements.contains(&g.compose(h)) {
                closed = false;
            }
        }
    }

    let mut all_inverses = true;
    for &g in &elements {
        if !elements.iter().any(|&h| g.compose(h) == id && h.compose(g) == id) {
            all_inverses = false;
        }
    }

    let wallpaper_set: BTreeSet<_> = elements.iter().map(|g| g.wallpaper_projection()).collect();

    Some(LayerGroupVerification {
        number: spec.number,
        symbol: spec.symbol.to_string(),
        crystal_system: spec.crystal_system.as_str().to_string(),
        wallpaper_projection: spec.wallpaper_projection.to_string(),
        expected_order: spec.expected_order,
        actual_order: elements.len(),
        wallpaper_order: wallpaper_set.len(),
        has_identity,
        closed_under_composition: closed,
        all_have_inverses: all_inverses,
        order_matches: elements.len() == spec.expected_order,
    })
}

/// Compute the deduplicated fractional-coordinate orbit of `(u, v, z)` under layer group `number`.
pub fn layer_group_orbit(number: u8, u: f64, v: f64, z: f64) -> Option<Vec<(f64, f64, f64)>> {
    let spec = get_layer_group(number)?;
    let elements = generate_group_elements(spec.generators);
    let mut quantized = BTreeSet::new();
    let mut orbit = Vec::new();
    for g in elements {
        let (nu, nv, nz) = g.apply(u, v, z);
        let key = (
            (nu * 1_000_000.0).round() as i64 % 1_000_000,
            (nv * 1_000_000.0).round() as i64 % 1_000_000,
            (nz * 1_000_000.0).round() as i64,
        );
        if quantized.insert(key) {
            orbit.push((nu, nv, nz));
        }
    }
    Some(orbit)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn verify_all_80_layer_groups_axioms_and_orders() {
        assert_eq!(ALL_80_LAYER_GROUPS.len(), 80);
        let mut wallpaper_names = BTreeSet::new();
        let mut symbols = BTreeSet::new();

        for num in 1u8..=80 {
            let v = verify_layer_group(num).expect("valid group number");
            assert_eq!(v.number, num);
            assert!(v.has_identity, "L_{num} ({}) missing identity", v.symbol);
            assert!(
                v.closed_under_composition,
                "L_{num} ({}) not closed under composition",
                v.symbol
            );
            assert!(
                v.all_have_inverses,
                "L_{num} ({}) missing inverses",
                v.symbol
            );
            assert!(
                v.order_matches,
                "L_{num} ({}) expected order {}, got {}",
                v.symbol,
                v.expected_order,
                v.actual_order
            );
            assert!(symbols.insert(v.symbol.clone()), "duplicate symbol {}", v.symbol);
            wallpaper_names.insert(v.wallpaper_projection.clone());
        }

        // All 17 2D wallpaper groups are covered by projections of the 80 layer groups.
        assert_eq!(wallpaper_names.len(), 17);
    }

    #[test]
    fn canonical_general_position_orbits_match_group_orders() {
        // Generic Wyckoff point has trivial stabilizer -> |orbit| = |G|
        for &(num, expected_order) in &[(1, 1), (7, 4), (19, 4), (37, 8), (55, 8), (61, 16), (80, 24)] {
            let orbit = layer_group_orbit(num, 0.137, 0.293, 0.411).unwrap();
            assert_eq!(orbit.len(), expected_order, "general orbit mismatch for L_{num}");
        }
        // Special Wyckoff point (0, 0, 0) in p6/mmm (L_80) has full stabilizer -> orbit size 1
        let origin_orbit = layer_group_orbit(80, 0.0, 0.0, 0.0).unwrap();
        assert_eq!(origin_orbit.len(), 1);
    }
}
