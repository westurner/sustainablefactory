#!/usr/bin/env python
"""
rename_with_underscore.py - add an underscore prefix to filenames
"""

import glob
import logging
import pytest
import sys
import unittest
from pathlib import Path

__version__ = "0.0.1"


def rename_with_underscores(raise_on_error=True) -> list[tuple[str,str]]:
    """mainfunc

    Arguments:
         (str): ...

    Keyword Arguments:
         (str): ...

    Returns:
        list of paths (old, new)

    Raises:
        Exception: ...
    """
    files = glob.glob('*')
    paths = [Path(f) for f in files]
    newpaths = []
    for p in paths:
        newname = '_' + str(p)
        newpath = Path(newname)
        if newpath.exists():
            errmsg = "There is already a file named: %r" % newpath
            log.error(errmsg)
            if raise_on_error:
                raise ValueError(errmsg)
        renamedpath = p.rename(newname)
        newpaths.append((p, renamedpath))
        print(('old', p, 'new', newpath))
    return newpaths




class Test_rename_with_underscores(unittest.TestCase):

    def setUp(self):
        pass

    def test_rename_with_underscores(self):
        pass

    def tearDown(self):
        pass


#def test_rename_with_underscores():
@pytest.mark.parametrize('', [
    [],
])
def test_rename_with_underscores():
    raise NotImplementedError()


def test_main():
    """test the main(sys.argv) CLI function"""
    raise NotImplementedError()


@pytest.mark.parametrize('argv', [
    None,
    [],

]
def test_main(argv):
    """test the main(sys.argv) CLI function"""
    output = main(argv)
    raise NotImplementedError()


def main(argv:list[str]|None=None):
    """
    rename_with_underscores main() function

    Keyword Arguments:
        argv (list): commandline arguments (e.g. sys.argv[1:])
    Returns:
        int:
    """
    import argparse

    prs = argparse.ArgumentParser(
        usage="%(prog)s [-h][-v] : args")

    prs.add_argument(
        '-v', '--verbose',
        dest='verbose',
        action='store_true',)
    prs.add_argument(
        '-q', '--quiet',
        dest='quiet',
        action='store_true',)
    prs.add_argument(
        '-t', '--test',
        dest='run_tests',
        action='store_true',)
    prs.add_argument(
        '--version',
        dest='version',
        action='store_true')



    argv = list(argv) if argv else []
    (opts, args) = prs.parse_known_args(args=argv)
    loglevel = logging.INFO
    if opts.verbose:
        loglevel = logging.DEBUG
    elif opts.quiet:
        loglevel = logging.ERROR
    logging.basicConfig(level=loglevel)
    log = logging.getLogger('main')
    log.debug('argv: %r', argv)
    log.debug('opts: %r', opts)
    log.debug('args: %r', args)

    if opts.version:
        print(__version__)

    if opts.run_tests:
        sys.argv = [sys.argv[0]] + args
        return unittest.main()

        # import subprocess
        # return subprocess.call(['pytest', '-v', '-l'] + args + [__file__])

    EX_OK = 0
    output = rename_with_underscores()

    return EX_OK


if __name__ == "__main__":
    sys.exit(main(argv=sys.argv[1:]))
