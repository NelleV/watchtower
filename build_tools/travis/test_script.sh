#!/bin/bash
# This script is meant to be called by the "script" step defined in
# .travis.yml. See http://docs.travis-ci.com/ for more details.
# The behavior of the script is controlled by environment variabled defined
# in the .travis.yml in the top level folder of the project.

# License: 3-clause BSD
    
set -e
    
python --version
python -c "import numpy; print('numpy %s' % numpy.__version__)"
python -c "import pandas; print('pandas %s' % pandas.__version__)"

echo $GITHUB_API_TEST

run_tests() {
    TEST_CMD="pytest --showlocals --pyargs"

    # Get into a temp directory to run test from the installed scikit learn
    # and
    # check if we do not leave artifacts
    mkdir -p $TEST_DIR
    # We need the setup.cfg for the nose settings
    cp setup.cfg $TEST_DIR
    cd $TEST_DIR

    if [[ "$COVERAGE" == "true" ]]; then
        TEST_CMD="$TEST_CMD --with-coverage"
    fi
    $TEST_CMD watchtower
    
}

if [[ "$RUN_FLAKE8" == "true" ]]; then
    source build_tools/travis/flake8_diff.sh
fi

if [[ "$SKIP_TESTS" != "true" ]]; then
    run_tests
fi

if [[ "$BUILD_DOC" == "true" ]] && [["$TRAVIS_PULL_REQUEST" != "false"]]; then
  pushd doc
  make html
  popd
  doctr deploy .
fi


