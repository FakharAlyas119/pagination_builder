# Example App Structure

This directory contains the example Flutter application that demonstrates the usage of the Pagination Builder package.

## File Structure

- `main.dart` - The main entry point of the application that contains all example screens

## Example Screens

The example app includes the following screens, each demonstrating different aspects of the Pagination Builder package:

1. **Basic Example** - Shows the simplest way to use the package with the factory constructor
2. **Advanced Example** - Demonstrates using a custom controller for more control
3. **API Example** - Shows integration with a REST API using a custom data provider
4. **State Handling Example** - Demonstrates handling different pagination states
5. **Database Example** - Shows integration with a local SQLite database

## Models

The example includes two data models:

- `User` - Used in the API example to represent user data from a REST API
- `Task` - Used in the database example to represent task data from a local database

## Data Providers

The example includes two custom implementations of the `PaginationDataProvider` interface:

- `ApiUserProvider` - Fetches user data from a REST API
- `DatabaseTaskProvider` - Fetches task data from a local SQLite database

## Helper Classes

- `DatabaseHelper` - Manages the SQLite database for the database example