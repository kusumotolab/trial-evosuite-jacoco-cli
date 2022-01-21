#!/bin/bash

EVOSUITE_VERSION=1.2.0
JACOCO_VERSION=0.8.7
JUNIT_VERSION=4.13.2
HAMCREST_VERSION=1.3

function init() {
    mkdir -p tmp

    if [ ! -d evosuite ]; then
        mkdir evosuite
        curl -L -o evosuite/evosuite.jar https://github.com/EvoSuite/evosuite/releases/download/v$EVOSUITE_VERSION/evosuite-$EVOSUITE_VERSION.jar
        curl -L -o evosuite/runtime.jar https://github.com/EvoSuite/evosuite/releases/download/v$EVOSUITE_VERSION/evosuite-standalone-runtime-$EVOSUITE_VERSION.jar
    fi

    if [ ! -d jacoco ]; then
        curl -L -o tmp/jacoco-$JACOCO_VERSION.zip https://github.com/jacoco/jacoco/releases/download/v$JACOCO_VERSION/jacoco-$JACOCO_VERSION.zip
        unzip tmp/jacoco-$JACOCO_VERSION.zip -d jacoco
    fi

    if [ ! -d junit ]; then
        mkdir junit
        curl -L -o junit/junit.jar https://search.maven.org/remotecontent?filepath=junit/junit/$JUNIT_VERSION/junit-$JUNIT_VERSION.jar
        curl -L -o junit/hamcrest.jar https://search.maven.org/remotecontent?filepath=org/hamcrest/hamcrest-core/$HAMCREST_VERSION/hamcrest-core-$HAMCREST_VERSION.jar
    fi
}

function instrument() {
    echo '>> compiling generated test file'
    javac -d build/test -cp build/main:evosuite/evosuite.jar evosuite-tests/sample/*.java

    echo '>> executing class file instrumentation'
    java -jar jacoco/lib/jacococli.jar instrument build/main --dest build/instrument
    
    echo '>> executing instrumented test class'
    java -javaagent:jacoco/lib/jacocoagent.jar -cp junit/*:evosuite/runtime.jar:build/instrument:build/test org.junit.runner.JUnitCore sample.Example_ESTest
}

function non-instrument() {
    echo '>> change setting of evosuite-test (without separate classloader)'
    sed -i -e 's/separateClassLoader = true/separateClassLoader = false/' evosuite-tests/sample/Example_ESTest.java

    echo '>> compiling generated test file'
    javac -d build/test -cp build/main:evosuite/evosuite.jar evosuite-tests/sample/*.java

    echo '>> executing non-instrumented test class'
    java -javaagent:jacoco/lib/jacocoagent.jar -cp junit/*:evosuite/evosuite.jar:build/main:build/test org.junit.runner.JUnitCore sample.Example_ESTest
}


# validation
if [[ $1 != 'instrument' ]] && [[ $1 != 'non-instrument' ]]; then
  echo ">> you have to choose instrument or non-instrument version"
  echo ">> $0 [ instrument | non-instrument ]"
  exit 1
fi

# main
init

echo '>> compiling source java file'
javac -d build/main src/**/**.java

echo '>> generating evosuite test'
java -jar evosuite/evosuite.jar -projectCP build/main -class sample.Example

# You can choose 2 way
if [[ $1 = 'instrument' ]] ; then
  echo '>> you choose instrument version'
  instrument
elif [[ $1 = 'non-instrument' ]] ; then
  echo '>> you choose non-instrument version'
  non-instrument
fi

echo '>> generating execution report'
java -jar jacoco/lib/jacococli.jar report jacoco.exec --sourcefiles src --classfiles build/main --html report

echo '>> open report/index.html'
