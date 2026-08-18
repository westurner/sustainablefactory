#!/bin/bash

doPostRenameTo() {
  oldname=$1
  newname=$2
  olddirname=$(dirname "${oldname}")
  newbasename=$(basename "${newname}")
  previewmode=${3:-}

  if [ "${previewmode}" ]; then
    cmd="echo"
  else
    cmd=
  fi

  if [ "${oldname}" = "${newname}" ]; then
    echo "ERROR: oldname==newname: ${oldname}"
    return 2
  fi

  echo "## failed.todo.log.sh -- $(date -Is)" > failed.todo.log.sh

  (set -e -x;
    cd "${olddirname}";
    test -f "${oldname}";
    test ! -f "${newbasename}";
    $cmd rm -v "${oldname}";
    $cmd ln -s ../"${newbasename}";
  ) || (
    echo "ERROR: doPostRenameTo Failed: ${oldname} -> ${newname}" >&2;
    printf 'doPostRenameTo %q %q\n' "${oldname}" "${newname}" | tee -a failed.todo.log.sh;
  )
}

renamebatch1() {
    echo "Starting renamebatch1 ..."
    doPostRenameTo "data/chats/batteries/_Lignolux Enhances Fusion Production Design  .json" "data/chats/batteries/_Lignolux Enhances Fusion Production Design.json"
    doPostRenameTo "data/chats/batteries/_Lignolux Enhances Fusion Production Design  .md" "data/chats/batteries/_Lignolux Enhances Fusion Production Design.md"
    doPostRenameTo "data/chats/batteries/_Lignolux-Enhances-Fusion-Production-Design (2).json" "data/chats/batteries/_Lignolux-Enhances-Fusion-Production-Design.json"
    doPostRenameTo "data/chats/batteries/_Lignolux-Enhances-Fusion-Production-Design (2).md" "data/chats/batteries/_Lignolux-Enhances-Fusion-Production-Design.md"
    doPostRenameTo "data/chats/carbons/_Making-Oxygenated-CNTs-from-Air (2).json" "data/chats/carbons/_Making-Oxygenated-CNTs-from-Air.json"
    doPostRenameTo "data/chats/carbons/_Making-Oxygenated-CNTs-from-Air (2).md" "data/chats/carbons/_Making-Oxygenated-CNTs-from-Air.md"
    doPostRenameTo "data/chats/communications/_Neutrinos-and-Black-Holes-and-Fracture.json" "data/chats/communications/_Neutrons-and-Black-Holes-and-Fracture.json"
    doPostRenameTo "data/chats/communications/_Neutrinos-and-Black-Holes-and-Fracture.md" "data/chats/communications/_Neutrons-and-Black-Holes-and-Fracture.md"
    doPostRenameTo "data/chats/fiber/_Red-and-Blue-Laser-Beam-Mixing (1).json" "data/chats/fiber/_Red-and-Blue-Laser-Beam-Mixing.json"
    doPostRenameTo "data/chats/fiber/_Red-and-Blue-Laser-Beam-Mixing (1).md" "data/chats/fiber/_Red-and-Blue-Laser-Beam-Mixing.md"
    doPostRenameTo "data/chats/ions/_Lignolux Enhances Fusion Production Design  .json" "data/chats/ions/_Lignolux Enhances Fusion Production Design.json"
    doPostRenameTo "data/chats/ions/_Lignolux Enhances Fusion Production Design  .md" "data/chats/ions/_Lignolux Enhances Fusion Production Design.md"
    doPostRenameTo "data/chats/ions/_Lignolux-Enhances-Fusion-Production-Design (2).json" "data/chats/ions/_Lignolux-Enhances-Fusion-Production-Design.json"
    doPostRenameTo "data/chats/ions/_Lignolux-Enhances-Fusion-Production-Design (2).md" "data/chats/ions/_Lignolux-Enhances-Fusion-Production-Design.md"
    doPostRenameTo "data/chats/nuclear-fusion/_Lignolux Enhances Fusion Production Design  .json" "data/chats/nuclear-fusion/_Lignolux Enhances Fusion Production Design.json"
    doPostRenameTo "data/chats/nuclear-fusion/_Lignolux Enhances Fusion Production Design  .md" "data/chats/nuclear-fusion/_Lignolux Enhances Fusion Production Design.md"
    doPostRenameTo "data/chats/nuclear-fusion/_Lignolux-Enhances-Fusion-Production-Design (2).json" "data/chats/nuclear-fusion/_Lignolux-Enhances-Fusion-Production-Design.json"
    doPostRenameTo "data/chats/nuclear-fusion/_Lignolux-Enhances-Fusion-Production-Design (2).md" "data/chats/nuclear-fusion/_Lignolux-Enhances-Fusion-Production-Design.md"
    doPostRenameTo "data/chats/physics/_Neutrinos-and-Black-Holes-and-Fracture.json" "data/chats/physics/_Neutrons-and-Black-Holes-and-Fracture.json"
    doPostRenameTo "data/chats/physics/_Neutrinos-and-Black-Holes-and-Fracture.md" "data/chats/physics/_Neutrons-and-Black-Holes-and-Fracture.md"

    echo "... DONE"
    echo ""
}

main() {
    (set -e -x; renamebatch1)
}

main