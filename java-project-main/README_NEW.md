# Spacecraft Dashboard

A comprehensive web application for managing spacecraft parameters and data. Built with JSP, JavaScript, and SQLite database.

## Project Overview

The Spacecraft Dashboard is a full-featured web application designed for aerospace engineers and researchers to manage spacecraft parameters, subsystem data, and mission information. The application provides a user-friendly interface for creating, viewing, editing, and organizing spacecraft data with advanced search and navigation capabilities.

## Features

### Core Functionality
- **Record Management**: Create, read, update, and delete spacecraft records
- **Dynamic Page ID Generation**: Automatic page ID generation using spacecraft name, subsystem, and page number
- **Parameter Customization**: 38 customizable parameters with editable labels
- **Database Navigation**: Navigate through records with Previous/Next buttons
- **Search & Suggestions**: Real-time search with intelligent suggestions
- **CSV Import/Export**: Import data from CSV files and export records

### Technical Features
- **SQLite Database**: Persistent data storage with automatic initialization
- **AJAX Operations**: Smooth user experience with asynchronous requests
- **Responsive Design**: Clean, professional interface that works on different screen sizes
- **Auto-sync**: Automatic synchronization between form fields and database
- **Parameter Labels**: Custom parameter labeling with automatic saving

## Technology Stack

- **Frontend**: HTML5, CSS3, JavaScript (ES6+)
- **Backend**: Java JSP (Jakarta Server Pages)
- **Database**: SQLite with JDBC
- **Server**: Apache Tomcat 10.1.43
- **Libraries**: 
  - SQLite JDBC Driver
  - JSON Processing
  - Apache Commons (File Upload, IO, Lang)
  - JSTL

## Project Structure

```
spacecraft-dashboard-final1/
├── index.jsp              # Main application interface
├── css/
│   └── style.css         # Application styles
├── js/
│   └── script.js         # Client-side JavaScript
├── WEB-INF/
│   ├── web.xml           # Web application configuration
│   ├── classes/
│   │   ├── DatabaseHelper.java
│   │   └── DatabaseHelper.class
│   └── lib/              # JAR dependencies
├── *.jsp files           # Server-side pages for various operations
├── spacecraft.db         # SQLite database file
└── README.md            # This file
```

## Installation & Setup

### Prerequisites
- Java 11 or higher
- Apache Tomcat 10.1.43 or compatible version
- Web browser (Chrome, Firefox, Safari, Edge)

### Installation Steps

1. **Download & Extract**:
   - Extract the project to Tomcat's webapps directory
   - Path should be: `{TOMCAT_HOME}/webapps/spacecraft-dashboard-final1/`

2. **Start Tomcat**:
   ```bash
   cd {TOMCAT_HOME}/bin
   ./startup.sh    # Linux/Mac
   startup.bat     # Windows
   ```

3. **Access Application**:
   - Open browser and navigate to: `http://localhost:8080/spacecraft-dashboard-final1/`
   - Database will be automatically initialized on first access

## How to Use

### Getting Started

1. **Access Main Interface**:
   - Open `index.jsp` in your browser to start using the application
   - The database will be automatically initialized on first access

2. **Add Data**:
   - Upload CSV files through the main interface
   - Or create new records manually using the form

### Main Features

#### Creating New Records
1. Click the "New Record" button (green button)
2. Fill in spacecraft name, subsystem name, and page number
3. Add a descriptive record title
4. Fill in parameter values as needed
5. Click "Save" to store the record

#### Navigation
- Use "Previous" and "Next" buttons to navigate between records
- Use the "Go" button with page number for direct navigation
- Search functionality provides quick access to specific records

#### CSV Operations
- **Import**: Use the CSV upload feature to import multiple records
- **Export**: Export individual records or all data to CSV format

#### Parameter Customization
- Click on parameter labels to customize them
- Labels are automatically saved and restored per record
- Each record can have its own custom parameter labels

### Page ID Format

Page IDs are automatically generated using the format:
- **Format**: `{4 chars from spacecraft}-{3 chars from subsystem}-{3 digit page number}`
- **Example**: "aryabhat" + "power" + "04" → "Arya-pow-004"

## Database Schema

### Tables

1. **Page_Info**
   - PageID (TEXT PRIMARY KEY)
   - PageNo (INTEGER UNIQUE)
   - SpacecraftName (TEXT)
   - SubsystemName (TEXT)
   - RecordTitle (TEXT)

2. **Page_Data**
   - PageID (TEXT PRIMARY KEY)
   - 38 parameter columns for spacecraft data
   - FOREIGN KEY reference to Page_Info

3. **Parameter_Labels**
   - PageID (TEXT)
   - ParameterIndex (INTEGER)
   - CustomLabel (TEXT)
   - Composite PRIMARY KEY (PageID, ParameterIndex)

## API Endpoints

The application includes various JSP endpoints for different operations:

- `checkPageId.jsp` - Check if page ID exists
- `deleteRecord.jsp` - Delete a record
- `exportAll.jsp` - Export all records to CSV
- `getDatabaseStatus.jsp` - Get database status
- `getNavigationInfo.jsp` - Get navigation data
- `getNextPageNumber.jsp` - Get next available page number
- `getParameterLabels.jsp` - Retrieve custom parameter labels
- `getRecord.jsp` - Get a specific record
- `getRecordByPageNo.jsp` - Get record by page number
- `getSuggestions.jsp` - Get search suggestions
- `saveParameterLabels.jsp` - Save custom parameter labels
- `saveRecord.jsp` - Save/update a record
- `searchRecords.jsp` - Search functionality
- `updateCSV.jsp` - Update CSV data
- `uploadCSV.jsp` - Upload CSV files

## Troubleshooting

- **Database Issues**: Database will be automatically recreated if corrupted
- **CSV Import Problems**: Ensure CSV format matches the 38-parameter structure
- **Search Not Working**: Check that database is properly initialized
- **Page Navigation Issues**: Verify records exist in the database

## Development

### Adding New Features
1. Create new JSP files for server-side operations
2. Add corresponding JavaScript functions in `script.js`
3. Update CSS in `style.css` for styling
4. Test thoroughly with different data sets

### Database Modifications
- Modify the table creation statements in `index.jsp`
- Update corresponding JSP files that interact with the database
- Ensure backward compatibility with existing data

## License

This project is developed for educational and research purposes.

---

# Source Code

Below is the complete source code for all files in the project:
