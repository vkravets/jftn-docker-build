#!/usr/bin/env bats

@test "python2 version" {
      python --version 2>&1 | grep "Python 2\."
}

@test "python3 version" {
      python3 --version 2>&1 | grep "Python 3\."
}

@test "java" {
  if [ $JAVA != "true" ] ; then
    skip "java not installed"
  fi

  java -version
}

@test "thrift" {
  
  thrift --version
}

@test "node" {

  node --version
}
