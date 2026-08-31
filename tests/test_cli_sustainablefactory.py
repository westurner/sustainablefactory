"""Tests for sustainablefactory CLI module."""

import pytest
from pathlib import Path
from unittest.mock import Mock, patch
from click.testing import CliRunner
from sustainablefactory.cli import main, parse, export_rdf, batch_export, info


@pytest.fixture
def cli_runner():
    """CLI test runner."""
    return CliRunner()


@pytest.fixture
def mock_process_step():
    """Mock ProcessStep object."""
    step = Mock()
    step.id = "step_1"
    step.label = "Test Process"
    step.cost_figures = ["$100", "$200"]
    step.latex_math = ["$x^2 + y^2$"]
    step.metrics = ["temperature", "pressure"]
    step.equipment = ["furnace", "reactor"]
    step.materials = ["iron", "carbon"]
    step.citations = ["source1", "source2"]
    step.tables = [1, 2]
    return step


@pytest.fixture
def mock_process_step_minimal():
    """Mock ProcessStep with minimal attributes."""
    step = Mock()
    step.id = "step_2"
    step.label = "Minimal Process"
    step.cost_figures = None
    step.latex_math = None
    step.metrics = None
    step.equipment = None
    step.materials = None
    step.citations = None
    step.tables = []
    return step


@pytest.fixture
def temp_markdown_file(tmp_path):
    """Create a temporary markdown file."""
    md_file = tmp_path / "test_process.md"
    md_file.write_text("# Test Process\n\nSome content")
    return md_file


@pytest.fixture
def temp_directory_with_files(tmp_path):
    """Create a temporary directory with test files."""
    md_file = tmp_path / "process1.md"
    md_file.write_text("# Process 1")

    json_file = tmp_path / "process2.json"
    json_file.write_text('{"data": "test"}')

    return tmp_path


class TestParseParseParseParseParseParse:
    """Test the parse command."""

    @patch("sustainablefactory.cli.parse_and_extract_from_markdown")
    def test_parse_with_full_attributes(
        self, mock_parse, cli_runner, mock_process_step, temp_markdown_file
    ):
        """Test parse command with complete step attributes."""
        mock_parse.return_value = [mock_process_step]

        result = cli_runner.invoke(parse, [str(temp_markdown_file)])

        assert result.exit_code == 0
        assert "Test Process" in result.output
        assert "Cost Figure: $100" in result.output
        assert "LaTeX Math: $x^2 + y^2$" in result.output
        assert "Metrics: temperature, pressure" in result.output
        assert "Equipment: furnace, reactor" in result.output
        assert "Materials: iron, carbon" in result.output
        assert "Source: source1" in result.output
        assert "Tables: 2 found" in result.output

    @patch("sustainablefactory.cli.parse_and_extract_from_markdown")
    def test_parse_with_minimal_attributes(
        self, mock_parse, cli_runner, mock_process_step_minimal, temp_markdown_file
    ):
        """Test parse command with minimal step attributes."""
        mock_parse.return_value = [mock_process_step_minimal]

        result = cli_runner.invoke(parse, [str(temp_markdown_file)])

        assert result.exit_code == 0
        assert "Minimal Process" in result.output
        # Should not contain skipped fields
        assert "Cost Figure" not in result.output

    @patch("sustainablefactory.cli.parse_and_extract_from_markdown")
    def test_parse_multiple_steps(
        self,
        mock_parse,
        cli_runner,
        mock_process_step,
        mock_process_step_minimal,
        temp_markdown_file,
    ):
        """Test parse command with multiple process steps."""
        mock_parse.return_value = [mock_process_step, mock_process_step_minimal]

        result = cli_runner.invoke(parse, [str(temp_markdown_file)])

        assert result.exit_code == 0
        assert "Test Process" in result.output
        assert "Minimal Process" in result.output

    @patch("sustainablefactory.cli.parse_and_extract_from_markdown")
    def test_parse_no_steps(self, mock_parse, cli_runner, temp_markdown_file):
        """Test parse command with no steps returned."""
        mock_parse.return_value = []

        result = cli_runner.invoke(parse, [str(temp_markdown_file)])

        assert result.exit_code == 0


class TestExportRdf:
    """Test the export_rdf command."""

    @patch("sustainablefactory.cli.generate_rdf_star")
    @patch("sustainablefactory.cli.parse_and_extract_from_markdown")
    def test_export_rdf_default_output(
        self,
        mock_parse,
        mock_rdf_gen,
        cli_runner,
        mock_process_step,
        temp_markdown_file,
    ):
        """Test export_rdf with default output file."""
        mock_parse.return_value = [mock_process_step]
        mock_rdf_gen.return_value = (
            "@prefix ex: <http://example.org/> .\nex:test a ex:Process ."
        )

        with cli_runner.isolated_filesystem():
            result = cli_runner.invoke(export_rdf, [str(temp_markdown_file)])

            assert result.exit_code == 0
            assert "Exported RDF-star to process_data.ttl" in result.output

            # Verify file was created and contains RDF data
            output_file = Path("process_data.ttl")
            assert output_file.exists()
            assert "@prefix ex:" in output_file.read_text()

    @patch("sustainablefactory.cli.generate_rdf_star")
    @patch("sustainablefactory.cli.parse_and_extract_from_markdown")
    def test_export_rdf_custom_output(
        self,
        mock_parse,
        mock_rdf_gen,
        cli_runner,
        mock_process_step,
        temp_markdown_file,
    ):
        """Test export_rdf with custom output file."""
        mock_parse.return_value = [mock_process_step]
        mock_rdf_gen.return_value = "custom rdf content"

        with cli_runner.isolated_filesystem():
            result = cli_runner.invoke(
                export_rdf, [str(temp_markdown_file), "--output", "custom_output.ttl"]
            )

            assert result.exit_code == 0
            assert "Exported RDF-star to custom_output.ttl" in result.output
            assert Path("custom_output.ttl").exists()

    @patch("sustainablefactory.cli.generate_rdf_star")
    @patch("sustainablefactory.cli.parse_and_extract_from_markdown")
    def test_export_rdf_short_output_flag(
        self,
        mock_parse,
        mock_rdf_gen,
        cli_runner,
        mock_process_step,
        temp_markdown_file,
    ):
        """Test export_rdf with short -o flag."""
        mock_parse.return_value = [mock_process_step]
        mock_rdf_gen.return_value = "rdf data"

        with cli_runner.isolated_filesystem():
            result = cli_runner.invoke(
                export_rdf, [str(temp_markdown_file), "-o", "short_flag_output.ttl"]
            )

            assert result.exit_code == 0
            assert "short_flag_output.ttl" in result.output

    @patch("sustainablefactory.cli.generate_rdf_star")
    @patch("sustainablefactory.cli.parse_and_extract_from_markdown")
    def test_export_rdf_calls_generate_with_stem(
        self,
        mock_parse,
        mock_rdf_gen,
        cli_runner,
        mock_process_step,
        temp_markdown_file,
    ):
        """Test that generate_rdf_star is called with correct source prefix."""
        mock_parse.return_value = [mock_process_step]
        mock_rdf_gen.return_value = ""

        with cli_runner.isolated_filesystem():
            cli_runner.invoke(export_rdf, [str(temp_markdown_file)])

            mock_rdf_gen.assert_called_once()
            call_args = mock_rdf_gen.call_args
            assert call_args[1]["source_prefix"] == temp_markdown_file.stem


class TestBatchExport:
    """Test the batch_export command."""

    @patch("sustainablefactory.cli.generate_rdf_star")
    @patch("sustainablefactory.cli.parse_and_extract_from_markdown")
    def test_batch_export_multiple_files(
        self,
        mock_parse,
        mock_rdf_gen,
        cli_runner,
        mock_process_step,
        temp_directory_with_files,
    ):
        """Test batch_export with multiple files in directory."""
        mock_parse.return_value = [mock_process_step]
        mock_rdf_gen.return_value = "batch rdf"

        with cli_runner.isolated_filesystem():
            result = cli_runner.invoke(batch_export, [str(temp_directory_with_files)])

            assert result.exit_code == 0
            assert "Processing process1.md" in result.output
            assert "Processing process2.json" in result.output
            assert "Exported" in result.output
            assert Path("all_processes.ttl").exists()

    @patch("sustainablefactory.cli.generate_rdf_star")
    @patch("sustainablefactory.cli.parse_and_extract_from_markdown")
    def test_batch_export_custom_output(
        self,
        mock_parse,
        mock_rdf_gen,
        cli_runner,
        mock_process_step,
        temp_directory_with_files,
    ):
        """Test batch_export with custom output file."""
        mock_parse.return_value = [mock_process_step]
        mock_rdf_gen.return_value = "rdf"

        with cli_runner.isolated_filesystem():
            result = cli_runner.invoke(
                batch_export,
                [str(temp_directory_with_files), "--output", "custom_batch.ttl"],
            )

            assert result.exit_code == 0
            assert "custom_batch.ttl" in result.output

    @patch("sustainablefactory.cli.generate_rdf_star")
    @patch("sustainablefactory.cli.parse_and_extract_from_markdown")
    def test_batch_export_file_prefixing(
        self,
        mock_parse,
        mock_rdf_gen,
        cli_runner,
        mock_process_step,
        temp_directory_with_files,
    ):
        """Test that batch_export prefixes step IDs with filename."""
        mock_parse.return_value = [mock_process_step]
        mock_rdf_gen.return_value = ""

        with cli_runner.isolated_filesystem():
            cli_runner.invoke(batch_export, [str(temp_directory_with_files)])

            # Verify that generate_rdf_star was called with empty source_prefix
            # and that steps were prefixed
            mock_rdf_gen.assert_called_once()
            call_args = mock_rdf_gen.call_args
            assert call_args[1]["source_prefix"] == ""

            # Get the steps argument
            steps = call_args[0][0]
            # Each step should have been modified with file prefix
            for step in steps:
                assert "_" in step.id

    @patch("sustainablefactory.cli.generate_rdf_star")
    @patch("sustainablefactory.cli.parse_and_extract_from_markdown")
    def test_batch_export_with_single_file_argument(
        self,
        mock_parse,
        mock_rdf_gen,
        cli_runner,
        mock_process_step,
        temp_markdown_file,
    ):
        """Test batch_export when given a single file instead of directory."""
        mock_parse.return_value = [mock_process_step]
        mock_rdf_gen.return_value = ""

        with cli_runner.isolated_filesystem():
            result = cli_runner.invoke(batch_export, [str(temp_markdown_file)])

            assert result.exit_code == 0


class TestInfoCommand:
    """Test the info command."""

    def test_info_command(self, cli_runner):
        """Test info command output."""
        result = cli_runner.invoke(info, [])

        assert result.exit_code == 0
        assert "Sustainable Factory Process Modeling Tool" in result.output
        assert "Version: 0.1.0" in result.output


class TestMainGroup:
    """Test the main click group."""

    def test_main_help(self, cli_runner):
        """Test main group help."""
        result = cli_runner.invoke(main, ["--help"])

        assert result.exit_code == 0
        assert "parse" in result.output
        assert "export-rdf" in result.output
        assert "batch-export" in result.output
        assert "info" in result.output


@pytest.mark.parametrize(
    "command,expected_in_help",
    [
        ("parse", ["INPUT_FILE"]),
        ("export-rdf", ["INPUT_FILE", "output"]),
        ("batch-export", ["INPUT_DIR", "output"]),
        ("info", []),
    ],
)
def test_command_help(cli_runner, command, expected_in_help):
    """Test help for each CLI command using parametrize."""
    result = cli_runner.invoke(main, [command, "--help"])

    assert result.exit_code == 0
    for expected in expected_in_help:
        assert expected in result.output
