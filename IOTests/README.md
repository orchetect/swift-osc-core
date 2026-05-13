# SwiftOSC I/O Tests

This Swift package contains standardized integration tests to be run against all I/O extension repositories.

Each I/O extension repository contains GitHub Actions workflows which run these tests automatically along with their own build and test CI workflows.

This package may also be used as a live development testbed in order to update the tests that are contained within. Simply add the respective I/O extension repository as dependency to this package temporarily while developing or debugging the tests. Be sure to revert the changes to Package.swift once finished with development.