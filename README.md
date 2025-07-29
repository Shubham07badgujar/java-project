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

## index.jsp

```jsp
<%@ page import="java.sql.*" %>
<%@ page import="org.sqlite.JDBC" %>
<%@ page import="java.io.File" %>
<!DOCTYPE html>
<html>
<head>
    <title>Spacecraft</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=1">
    <script src="${pageContext.request.contextPath}/js/script.js?v=1"></script>
</head>
<body>
    <div class="container">
        <div class="left-panel">
            <h2>Spacecraft Data Management</h2>
            
            <div class="input-group">
                <label for="spacecraftName">Spacecraft Name:</label>
                <input type="text" id="spacecraftName" name="spacecraftName" list="spacecraftSuggestions" autocomplete="off">
                <datalist id="spacecraftSuggestions"></datalist>
            </div>
            
            <div class="input-group">
                <label for="subsystemName">Subsystem Name:</label>
                <input type="text" id="subsystemName" name="subsystemName" list="subsystemSuggestions" autocomplete="off">
                <datalist id="subsystemSuggestions"></datalist>
            </div>
            
            <div class="csv-upload">
                <h3>CSV Upload</h3>
                <label for="csvFile">Select CSV File:</label>
                <input type="file" id="csvFile" name="csvFile" accept=".csv">
                <button onclick="uploadCSV()">Upload CSV</button>
            </div>
            
            <div class="search-box">
                <h3>Search</h3>
                <div class="search-container">
                    <label for="searchInput">Search:</label>
                    <input type="text" id="searchInput" name="searchInput" placeholder="Search spacecraft or subsystem..." autocomplete="off">
                    <div id="searchSuggestions" class="search-suggestions"></div>
                    <button onclick="searchRecords()" class="search-btn">Search</button>
                </div>
            </div>
            
        </div>
        
        <div class="right-panel">
            <div class="page-info">
                <span>Page ID: <span id="pageIdDisplay">N/A</span></span>
                <span><label for="pageNoInput">Page No:</label> <input type="number" id="pageNoInput" name="pageNoInput" min="1" placeholder="Enter page no" style="width: 80px; padding: 2px 4px; border: 1px solid #ccc; border-radius: 3px;">
                    <button onclick="goToPage()" class="go-btn">Go</button>
                </span>
            </div>
            
            <div class="action-buttons">
                <div class="left-buttons">
                    <button onclick="createNewRecord()" class="new-btn" style="background-color: #4CAF50; color: white; padding: 8px 16px; border: none; border-radius: 4px; cursor: pointer; margin-right: 5px; font-weight: bold; box-shadow: 0 2px 4px rgba(0,0,0,0.2);" 
                            onmouseover="this.style.backgroundColor='#45a049'; this.style.boxShadow='0 3px 6px rgba(0,0,0,0.3)'" 
                            onmouseout="this.style.backgroundColor='#4CAF50'; this.style.boxShadow='0 2px 4px rgba(0,0,0,0.2)'">+ New Record</button>
                    <button onclick="saveRecord()" class="save-btn">Save</button>
                    <button onclick="deleteRecord()" class="delete-btn">Delete</button>
                    <button onclick="saveParameterLabelsInline()" class="save-labels-btn" style="background-color: #4CAF50; color: white; padding: 6px 12px; border: none; border-radius: 4px; cursor: pointer;">Save Labels</button>
                    <button onclick="exportToCSV()" class="export-btn">Export CSV</button>
                    <button onclick="exportAll()" class="export-all-btn">Export All</button>
                </div>
                <div class="right-buttons">
                    <button onclick="navigate(-1)">Previous</button>
                    <button onclick="navigate(1)">Next</button>
                </div>
            </div>
            
            <div class="table-center-wrap">
                <div class="dynamic-form-container">
                    <div class="title-section">
                        <label for="recordTitle">Title</label>
                        <input type="text" id="recordTitle" name="recordTitle" class="title-input" placeholder="Enter a unique title for this record">
                    </div>
                    
                    <div class="parameters-section">
                        <div class="parameters-header">
                            <h3>Parameters</h3>
                        </div>
                        
                        <div id="parametersContainer" class="parameters-container">
                            <!-- 38 parameter fields will be generated here -->
                        </div>
                    </div>
                </div>
            </div>
            
            <div id="statusMessage"></div>
            <div id="loadingIndicator" style="display: none; text-align: center; margin-top: 20px;">
                <p>Loading...</p>
            </div>
        </div>
    </div>
    
    <%!
        private String getParameterLabel(int index) {
            switch(index) {
                case 1: return "Spacecraft Name";
                case 2: return "Mission ID";
                case 3: return "Launch Date";
                case 4: return "Orbit Type";
                case 5: return "Payload Capacity";
                case 6: return "Fuel Capacity";
                case 7: return "Max Thrust";
                case 8: return "Engine Type";
                case 9: return "Communication Band";
                case 10: return "Power Output";
                case 11: return "Solar Array Size";
                case 12: return "Battery Capacity";
                case 13: return "Attitude Control";
                case 14: return "Navigation System";
                case 15: return "Thermal Control";
                case 16: return "Structural Material";
                case 17: return "Dry Mass";
                case 18: return "Wet Mass";
                case 19: return "Dimensions";
                case 20: return "Operational Lifetime";
                case 21: return "Data Rate";
                case 22: return "Onboard Storage";
                case 23: return "Redundancy Level";
                case 24: return "Failure Rate";
                case 25: return "Reliability";
                case 26: return "Radiation Tolerance";
                case 27: return "Temperature Range";
                case 28: return "Software Version";
                case 29: return "Firmware Version";
                case 30: return "Autonomy Level";
                case 31: return "Mission Objectives";
                case 32: return "Scientific Instruments";
                case 33: return "Propulsion System";
                case 34: return "Delta-V Capacity";
                case 35: return "Communication Delay";
                case 36: return "Ground Stations";
                case 37: return "Mission Cost";
                case 38: return "Development Time";
                default: return "Parameter " + index;
            }
        }
    %>
    
    <%
        // Initialize database if it doesn't exist
        String dbPath = getServletContext().getRealPath("/") + "spacecraft.db";
        // Set the database path as a context parameter for other JSP files
        getServletContext().setAttribute("dbPath", dbPath);
        File dbFile = new File(dbPath);
        
        if (!dbFile.exists()) {
            try {
                Class.forName("org.sqlite.JDBC");
                Connection conn = DriverManager.getConnection("jdbc:sqlite:" + dbPath);
                
                Statement stmt = conn.createStatement();
                stmt.executeUpdate("CREATE TABLE IF NOT EXISTS Page_Info (" +
                    "PageID TEXT PRIMARY KEY, " +
                    "PageNo INTEGER UNIQUE, " +
                    "SpacecraftName TEXT, " +
                    "SubsystemName TEXT, " +
                    "RecordTitle TEXT)");
                
                stmt.executeUpdate("CREATE TABLE IF NOT EXISTS Page_Data (" +
                    "PageID TEXT PRIMARY KEY, " +
                    "\"Spacecraft Name\" TEXT, \"Mission ID\" TEXT, \"Launch Date\" TEXT, " +
                    "\"Orbit Type\" TEXT, \"Payload Capacity\" TEXT, \"Fuel Capacity\" TEXT, " +
                    "\"Max Thrust\" TEXT, \"Engine Type\" TEXT, \"Communication Band\" TEXT, " +
                    "\"Power Output\" TEXT, \"Solar Array Size\" TEXT, \"Battery Capacity\" TEXT, " +
                    "\"Attitude Control\" TEXT, \"Navigation System\" TEXT, \"Thermal Control\" TEXT, " +
                    "\"Structural Material\" TEXT, \"Dry Mass\" TEXT, \"Wet Mass\" TEXT, " +
                    "\"Dimensions\" TEXT, \"Operational Lifetime\" TEXT, \"Data Rate\" TEXT, " +
                    "\"Onboard Storage\" TEXT, \"Redundancy Level\" TEXT, \"Failure Rate\" TEXT, " +
                    "\"Reliability\" TEXT, \"Radiation Tolerance\" TEXT, \"Temperature Range\" TEXT, " +
                    "\"Software Version\" TEXT, \"Firmware Version\" TEXT, \"Autonomy Level\" TEXT, " +
                    "\"Mission Objectives\" TEXT, \"Scientific Instruments\" TEXT, \"Propulsion System\" TEXT, " +
                    "\"Delta-V Capacity\" TEXT, \"Communication Delay\" TEXT, \"Ground Stations\" TEXT, " +
                    "\"Mission Cost\" TEXT, \"Development Time\" TEXT, " +
                    "FOREIGN KEY(PageID) REFERENCES Page_Info(PageID))");
                
                // Create Parameter_Labels table for custom parameter labels
                stmt.executeUpdate("CREATE TABLE IF NOT EXISTS Parameter_Labels (" +
                    "PageID TEXT NOT NULL, " +
                    "ParameterIndex INTEGER NOT NULL, " +
                    "CustomLabel TEXT NOT NULL, " +
                    "PRIMARY KEY (PageID, ParameterIndex), " +
                    "FOREIGN KEY(PageID) REFERENCES Page_Info(PageID))");
                
                conn.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    %>
    <script>
        var contextPath = '${pageContext.request.contextPath}';
        
        // Make currentPageId globally accessible
        window.currentPageId = null;
        
        function goToPage() {
            const pageNo = parseInt(document.getElementById('pageNoInput').value, 10);
            if (isNaN(pageNo) || pageNo < 1) {
                showStatus('Please enter a valid page number.', 'error');
                return;
            }
            setLoading(true);
            const xhr = new XMLHttpRequest();
            xhr.open('GET', contextPath + `/getRecordByPageNo.jsp?pageNo=${pageNo}`, true);
            xhr.timeout = 5000;
            xhr.onload = function() {
                setLoading(false);
                if (xhr.status === 200) {
                    try {
                        const result = JSON.parse(xhr.responseText);
                        if (result.pageId) {
                            loadRecord(result.pageId);
                            document.getElementById('pageNoInput').value = pageNo;
                        } else {
                            showStatus(result.error || 'No record found for this page number.', 'error');
                        }
                    } catch {
                        showStatus('Error parsing response.', 'error');
                    }
                } else {
                    showStatus('Failed to fetch record.', 'error');
                }
            };
            xhr.onerror = function() {
                setLoading(false);
                showStatus('Request failed.', 'error');
            };
            xhr.send();
        }
        
        // Generate 38 parameter fields in 2-column, 19-row layout
        function generateParameterFields() {
            const container = document.getElementById('parametersContainer');
            container.innerHTML = '';
            
            let html = '<div class="parameter-grid">';
            
            for (let row = 0; row < 19; row++) {
                html += '<div class="parameter-row">';
                for (let col = 0; col < 2; col++) {
                    const paramIndex = row * 2 + col + 1;
                    if (paramIndex <= 38) {
                        html += '<div class="parameter-cell">' +
                            '<div class="param-row">' +
                                '<div class="param-label">' +
                                    '<input type="text" id="paramLabel' + paramIndex + '" name="paramLabel' + paramIndex + '" ' +
                                           'class="param-label-input" placeholder="Parameter ' + paramIndex + '" ' +
                                           'onchange="handleLabelChange(' + paramIndex + ')">' +
                                '</div>' +
                                '<div class="param-value">' +
                                    '<input type="text" id="paramValue' + paramIndex + '" name="paramValue' + paramIndex + '" ' +
                                           'class="param-value-input" placeholder="Value" readonly>' +
                                '</div>' +
                            '</div>' +
                        '</div>';
                    }
                }
                html += '</div>';
            }
            
            html += '</div>';
            container.innerHTML = html;
            
            // Initialize default labels after DOM is created
            setTimeout(function() {
                initializeDefaultLabels();
            }, 100);
        }
        
        // Get default parameter label based on index
        function getDefaultParameterLabel(index) {
            const labels = {
                1: "Spacecraft Name", 2: "Mission ID", 3: "Launch Date", 4: "Orbit Type", 
                5: "Payload Capacity", 6: "Fuel Capacity", 7: "Max Thrust", 8: "Engine Type", 
                9: "Communication Band", 10: "Power Output", 11: "Solar Array Size", 12: "Battery Capacity", 
                13: "Attitude Control", 14: "Navigation System", 15: "Thermal Control", 16: "Structural Material", 
                17: "Dry Mass", 18: "Wet Mass", 19: "Dimensions", 20: "Operational Lifetime", 
                21: "Data Rate", 22: "Onboard Storage", 23: "Redundancy Level", 24: "Failure Rate", 
                25: "Reliability", 26: "Radiation Tolerance", 27: "Temperature Range", 28: "Software Version", 
                29: "Firmware Version", 30: "Autonomy Level", 31: "Mission Objectives", 32: "Scientific Instruments", 
                33: "Propulsion System", 34: "Delta-V Capacity", 35: "Communication Delay", 36: "Ground Stations", 
                37: "Mission Cost", 38: "Development Time"
            };
            return labels[index] || "Parameter " + index;
        }
        
        // Initialize default labels
        function initializeDefaultLabels() {
            for (let i = 1; i <= 38; i++) {
                const labelInput = document.getElementById('paramLabel' + i);
                if (labelInput) {
                    labelInput.value = getDefaultParameterLabel(i);
                }
            }
        }
        
        // Handle label change with improved logic
        let labelSaveTimeout = null;
        let pendingLabelChanges = {};
        
        function handleLabelChange(paramIndex) {
            console.log('Label changed for parameter', paramIndex);
            
            // Store the current label change
            const labelInput = document.getElementById('paramLabel' + paramIndex);
            if (labelInput) {
                pendingLabelChanges[paramIndex] = labelInput.value.trim();
            }
            
            // Clear existing timeout
            if (labelSaveTimeout) {
                clearTimeout(labelSaveTimeout);
            }
            
            // Set new timeout to save after 2 seconds of no changes
            labelSaveTimeout = setTimeout(function() {
                saveParameterLabelsInline();
            }, 2000);
        }
        
        // Save parameter labels (improved version)
        function saveParameterLabelsInline() {
            // Get currentPageId from the global script.js scope
            let pageId = window.currentPageId;
            
            // If no pageId exists, create a temporary one
            if (!pageId) {
                // Get spacecraft name and subsystem if available
                const spacecraftName = document.getElementById('spacecraftName')?.value?.trim() || 'Temp';
                const subsystemName = document.getElementById('subsystemName')?.value?.trim() || 'tmp';
                
                // Generate a temporary pageId following the same format: 4-3-3 pattern
                const spacecraftPrefix = spacecraftName.substring(0, 4);
                const subsystemPrefix = subsystemName.substring(0, 3).toLowerCase();
                const formattedSpacecraft = spacecraftPrefix.charAt(0).toUpperCase() + spacecraftPrefix.slice(1).toLowerCase();
                const timestamp = Date.now().toString().slice(-3); // Use last 3 digits of timestamp
                
                pageId = `${formattedSpacecraft}-${subsystemPrefix}-${timestamp}`;
                
                // Set the pageId globally
                window.currentPageId = pageId;
                currentPageId = pageId;
                
                // Update the display
                document.getElementById('pageIdDisplay').textContent = pageId;
                
                console.log('Created temporary PageID for parameter labels:', pageId);
            }
            
            let params = [];
            params.push('pageId=' + encodeURIComponent(pageId));
            
            // Collect all parameter labels that differ from defaults
            let hasChanges = false;
            for (let i = 1; i <= 38; i++) {
                const labelInput = document.getElementById('paramLabel' + i);
                if (labelInput) {
                    const labelValue = labelInput.value.trim();
                    const defaultValue = getDefaultParameterLabel(i);
                    if (labelValue && labelValue !== defaultValue) {
                        params.push('paramLabel' + i + '=' + encodeURIComponent(labelValue));
                        hasChanges = true;
                    }
                }
            }
            
            if (!hasChanges) {
                console.log('No parameter label changes to save');
                return;
            }
            
            const paramString = params.join('&');
            console.log('Saving parameter labels for PageID:', pageId);
            console.log('Parameters:', paramString);
            
            const xhr = new XMLHttpRequest();
            xhr.open('POST', contextPath + '/saveParameterLabels.jsp', true);
            xhr.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
            xhr.timeout = 5000;
            
            xhr.onload = function() {
                if (xhr.status === 200) {
                    try {
                        const result = JSON.parse(xhr.responseText);
                        if (result.success) {
                            console.log('Parameter labels saved successfully. Saved count:', result.savedLabels);
                            // Show success message with a custom status function or alert
                            if (typeof showStatus === 'function') {
                                showStatus(`Parameter labels saved successfully! (${result.savedLabels} labels saved)`, 'success');
                            } else {
                                alert(`Parameter labels saved successfully! (${result.savedLabels} labels saved)`);
                            }
                        } else {
                            console.error('Error saving parameter labels:', result.error);
                            if (typeof showStatus === 'function') {
                                showStatus('Error saving parameter labels: ' + result.error, 'error');
                            } else {
                                alert('Error saving parameter labels: ' + result.error);
                            }
                        }
                    } catch (e) {
                        console.error('Error parsing parameter labels save response:', e);
                        if (typeof showStatus === 'function') {
                            showStatus('Error parsing parameter labels response', 'error');
                        } else {
                            alert('Error parsing parameter labels response');
                        }
                    }
                } else {
                    console.error('Failed to save parameter labels. Status:', xhr.status);
                    if (typeof showStatus === 'function') {
                        showStatus('Failed to save parameter labels. Status: ' + xhr.status, 'error');
                    } else {
                        alert('Failed to save parameter labels. Status: ' + xhr.status);
                    }
                }
            };
            
            xhr.onerror = function() {
                console.error('Parameter labels save request failed');
                if (typeof showStatus === 'function') {
                    showStatus('Parameter labels save request failed', 'error');
                } else {
                    alert('Parameter labels save request failed');
                }
            };
            
            xhr.send(paramString);
        }
        
        // Load parameter labels (inline version)
        function loadParameterLabelsInline(pageId) {
            if (!pageId) {
                console.log('No PageID provided for loading labels');
                return;
            }
            
            const xhr = new XMLHttpRequest();
            xhr.open('GET', contextPath + '/getParameterLabels.jsp?pageId=' + encodeURIComponent(pageId), true);
            xhr.timeout = 5000;
            
            xhr.onload = function() {
                if (xhr.status === 200) {
                    try {
                        const result = JSON.parse(xhr.responseText);
                        if (result.success) {
                            const labels = result.labels;
                            console.log('Loaded parameter labels:', labels);
                            
                            // Apply custom labels to the UI
                            for (let i = 1; i <= 38; i++) {
                                const labelInput = document.getElementById('paramLabel' + i);
                                if (labelInput) {
                                    const customLabel = labels['param' + i];
                                    if (customLabel) {
                                        labelInput.value = customLabel;
                                    } else {
                                        labelInput.value = getDefaultParameterLabel(i);
                                    }
                                }
                            }
                        } else {
                            console.error('Error loading parameter labels:', result.error);
                            // Fall back to default labels
                            initializeDefaultLabels();
                        }
                    } catch (e) {
                        console.error('Error parsing parameter labels response:', e);
                        initializeDefaultLabels();
                    }
                } else {
                    console.error('Failed to load parameter labels. Status:', xhr.status);
                    initializeDefaultLabels();
                }
            };
            
            xhr.onerror = function() {
                console.error('Parameter labels load request failed');
                initializeDefaultLabels();
            };
            
            xhr.send();
        }
        
        // Apply pending parameter labels after record is saved
        function applyPendingParameterLabels(pageId) {
            if (window.pendingParameterLabels && Object.keys(window.pendingParameterLabels).length > 0) {
                console.log('Applying pending parameter labels for PageID:', pageId);
                window.currentPageId = pageId;
                saveParameterLabelsInline();
                window.pendingParameterLabels = null;
            }
        }
        
        // Expose function to global scope
        window.applyPendingParameterLabels = applyPendingParameterLabels;
        
        // Create new record function
        function createNewRecord() {
            console.log('Creating new record...');
            
            // Clear all form fields
            clearFormFields();
            
            // Reset global variables
            window.currentPageId = null;
            currentPageId = null;
            currentPageNo = null;
            
            // Clear the page ID display
            document.getElementById('pageIdDisplay').textContent = 'N/A';
            
            // Clear parameter labels to default
            initializeDefaultLabels();
            
            // Get next available page number
            getNextPageNumber();
            
            // Show status message
            if (typeof showStatus === 'function') {
                showStatus('Ready to create new record. Fill in the details and click Save.', 'info');
            }
            
            // Focus on the first input field
            const spacecraftNameInput = document.getElementById('spacecraftName');
            if (spacecraftNameInput) {
                spacecraftNameInput.focus();
            }
        }
        
        // Get next available page number
        function getNextPageNumber() {
            const xhr = new XMLHttpRequest();
            xhr.open('GET', contextPath + '/getNextPageNumber.jsp', true);
            xhr.timeout = 3000;
            
            xhr.onload = function() {
                if (xhr.status === 200) {
                    try {
                        const result = JSON.parse(xhr.responseText);
                        if (result.success && result.nextPageNo) {
                            document.getElementById('pageNoInput').value = result.nextPageNo;
                            console.log('Set next page number to:', result.nextPageNo);
                        }
                    } catch (e) {
                        console.error('Error parsing next page number response:', e);
                        // Default to 1 if there's an error
                        document.getElementById('pageNoInput').value = 1;
                    }
                } else {
                    console.log('Failed to get next page number, defaulting to 1');
                    document.getElementById('pageNoInput').value = 1;
                }
            };
            
            xhr.onerror = function() {
                console.log('Network error getting next page number, defaulting to 1');
                document.getElementById('pageNoInput').value = 1;
            };
            
            xhr.send();
        }
        
        // Expose createNewRecord to global scope
        window.createNewRecord = createNewRecord;
        
        // Initialize parameter fields on page load
        document.addEventListener('DOMContentLoaded', function() {
            generateParameterFields();
        });
    </script>
    <style>
.table-center-wrap {
    display: flex;
    justify-content: center;
    align-items: flex-start;
    min-height: 70vh;
    width: 100%;
    margin-top: 20px;
}

.dynamic-form-container {
    width: 90%;
    background: white;
    border-radius: 8px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.15);
    padding: 20px;
}

.title-section {
    margin-bottom: 20px;
    padding-bottom: 15px;
    border-bottom: 2px solid #eee;
}

.title-section label {
    display: block;
    font-weight: bold;
    margin-bottom: 8px;
    color: #333;
}

.title-input {
    width: 100%;
    padding: 10px;
    border: 2px solid #ddd;
    border-radius: 4px;
    font-size: 16px;
}

.title-input:focus {
    border-color: #2196F3;
    outline: none;
}

.parameters-section {
    background: #000;
    border-radius: 8px;
    padding: 20px;
    border: 2px solid #333;
}

.parameters-header {
    display: flex;
    justify-content: center;
    align-items: center;
    margin-bottom: 20px;
}

.parameters-header h3 {
    margin: 0;
    color: #fff;
    font-size: 1.5em;
    text-align: center;
}

.parameters-container {
    max-height: 600px;
    overflow-y: auto;
}

.parameter-grid {
    display: flex;
    flex-direction: column;
    gap: 8px;
}

.parameter-row {
    display: flex;
    gap: 8px;
}

.parameter-cell {
    flex: 1;
    background: #111;
    border: 1px solid #333;
    border-radius: 6px;
    padding: 8px;
}

.parameter-cell .param-row {
    display: flex;
    align-items: center;
    gap: 8px;
}

.param-label {
    flex: 1;
}

.param-value {
    flex: 1;
}

.param-label-input,
.param-value-input {
    width: 100%;
    padding: 8px;
    border: 1px solid #444;
    border-radius: 4px;
    font-size: 12px;
    background: #222;
    color: #fff;
    box-sizing: border-box;
}

.param-label-input {
    background: #1a1a1a;
    color: #fff;
    font-weight: 500;
    border: 1px solid #555;
    cursor: text;
}

.param-label-input:hover {
    border-color: #777;
    background: #1e1e1e;
}

.param-label-input:focus {
    border-color: #2196F3;
    background: #1a1a1a;
    box-shadow: 0 0 5px rgba(33, 150, 243, 0.3);
}

.param-value-input {
    background: #2a2a2a;
    color: #ccc;
    cursor: not-allowed;
}

.param-label-input:focus {
    border-color: #2196F3;
    outline: none;
    background: #1a1a1a;
}

.param-value-input:focus {
    outline: none;
    background: #2a2a2a;
}

/* Custom scrollbar for the parameters container */
.parameters-container::-webkit-scrollbar {
    width: 8px;
}

.parameters-container::-webkit-scrollbar-track {
    background: #000;
}

.parameters-container::-webkit-scrollbar-thumb {
    background: #333;
    border-radius: 4px;
}

.parameters-container::-webkit-scrollbar-thumb:hover {
    background: #555;
}

.enhanced-table {
    width: 90%;
    margin: 0 auto;
    background: black;
    border-radius: 8px;
    border-collapse: separate;
    border-spacing: 0;
    box-shadow: 0 2px 8px rgba(0,0,0,0.15);
}
.enhanced-table th {
    padding: 6px 0;
    border-bottom: 2px solid #444;
    text-align: center;
}
.enhanced-table td.param-cell {
    background: #181818;
    border: 1px solid #333;
    padding: 4px 6px 4px 6px;
    vertical-align: middle;
    text-align: center;
    min-width: 220px;
}
.enhanced-table .param-row {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
}
.enhanced-table .param-label {
    color: #fff;
    font-size: 0.75em;
    font-weight: 500;
    min-width: 120px;
    flex-shrink: 0;
}
.enhanced-table .param-value {
    flex: 1;
}



.enhanced-table .param-value input {
    max-width: 140px;
    width: 100%;
    padding: 3px 5px;
    border-radius: 4px;
    border: 1px solid #555;
    background: #222;
    color: #fff;
    font-size: 0.75em;
}
@media (max-width: 900px) {
    .enhanced-table td.param-cell { min-width: 150px; }
}
</style>
</body>
</html>
```


## Script.js file cource code 

let currentPageId = null;
let currentPageNo = 1; // Start with page 1 instead of 0
let totalPages = 0;
let activeRequests = 0;

// Database-based navigation system - no arrays needed!

// Initialize the application
document.addEventListener('DOMContentLoaded', function() {
    
    setTimeout(function() {
        setupAutosuggestions();
        setupAutoSyncToCSV(); // Initialize auto-sync functionality
        
        // Load the first record from database
        setTimeout(function() {
            loadFirstPage();
        }, 1000);
    }, 500);
    
    // Set up event listeners
    document.getElementById('spacecraftName').addEventListener('input', function() {
        updateSuggestions('spacecraft');
    });
    
    document.getElementById('subsystemName').addEventListener('input', function() {
        updateSuggestions('subsystem');
    });
    
    document.getElementById('searchInput').addEventListener('keypress', function(e) {
        if (e.key === 'Enter') {
            searchRecords();
        }
    });
    
    // Enhanced search with auto-suggestions
    document.getElementById('searchInput').addEventListener('input', function() {
        handleSearchInput();
    });
    
    document.getElementById('searchInput').addEventListener('keydown', function(e) {
        handleSearchKeyNavigation(e);
    });
    
    // Close suggestions when clicking outside
    document.addEventListener('click', function(e) {
        if (!e.target.closest('.search-container')) {
            hideSearchSuggestions();
        }
    });
});

function setLoading(state) {
    const loader = document.getElementById('loadingIndicator');
    if (loader) {
        loader.style.display = state ? 'block' : 'none';
    }
    activeRequests += state ? 1 : -1;
    if (activeRequests < 0) activeRequests = 0;
}

function loadTotalPages() {
    setLoading(true);
    const xhr = new XMLHttpRequest();
    xhr.open('GET', contextPath + '/getTotalPages.jsp', true);
    xhr.timeout = 5000;
    
    xhr.onload = function() {
        setLoading(false);
        if (xhr.status === 200) {
            totalPages = parseInt(xhr.responseText) || 0;
            console.log('Total pages loaded:', totalPages);
            
            // Load page list for navigation
            loadPageList();
        }
    };
    
    xhr.onerror = function() {
        setLoading(false);
        showStatus('Error loading page count', 'error');
    };
    
    xhr.ontimeout = function() {
        setLoading(false);
        showStatus('Request timed out', 'error');
    };
    
    xhr.send();
}

function loadFirstPage() {
    console.log('Loading first page from database...');
    
    // First check if database has any records
    const xhr = new XMLHttpRequest();
    xhr.open('GET', contextPath + '/getDatabaseStatus.jsp', true);
    xhr.onload = function() {
        if (xhr.status === 200) {
            try {
                const status = JSON.parse(xhr.responseText);
                if (status.success && status.databaseReady && status.firstRecord) {
                    // Database has records, load the first one
                    console.log('Database ready, loading first record:', status.firstRecord.pageId);
                    loadRecord(status.firstRecord.pageId);
                } else {
                    // Database is empty or not ready
                    console.log('Database empty or not ready');
                    clearFormFields();
                    showStatus('Database is empty. Upload CSV files to get started.', 'info');
                }
            } catch (e) {
                console.error('Error checking database status:', e);
                clearFormFields();
                showStatus('Error checking database status', 'error');
            }
        } else {
            console.error('Failed to check database status');
            clearFormFields();
        }
    };
    xhr.onerror = function() {
        console.error('Network error checking database status');
        clearFormFields();
    };
    xhr.send();
}

function clearFormFields() {
    // Clear all form fields when no data is available
    document.getElementById('pageIdDisplay').textContent = 'N/A';
    document.getElementById('pageNoInput').value = '';
    document.getElementById('spacecraftName').value = '';
    document.getElementById('subsystemName').value = '';
    document.getElementById('recordTitle').value = '';
    
    // Clear all parameter fields
    for (let i = 1; i <= 38; i++) {
        const valueInput = document.getElementById(`paramValue${i}`);
        if (valueInput) {
            valueInput.value = '';
        }
    }
    
    currentPageId = null;
    currentPageNo = 1;
}



function setupAutosuggestions() {
    // Add event listeners for real-time suggestions
    const spacecraftInput = document.getElementById('spacecraftName');
    const subsystemInput = document.getElementById('subsystemName');
    const pageNoInput = document.getElementById('pageNoInput');
    
    if (spacecraftInput) {
        spacecraftInput.addEventListener('input', function() {
            updateSuggestions('spacecraft');
        });
        
        // When spacecraft is selected, update subsystem suggestions
        spacecraftInput.addEventListener('change', function() {
            updateSubsystemSuggestionsForSpacecraft(this.value.trim());
        });
    }
    
    if (subsystemInput) {
        subsystemInput.addEventListener('input', function() {
            updateSuggestions('subsystem');
        });
    }
    
    // Add Enter key support for page number input
    if (pageNoInput) {
        pageNoInput.addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                e.preventDefault();
                goToPage();
            }
        });
    }
    
    // Initial suggestions
    updateSuggestions('spacecraft');
    updateSuggestions('subsystem');
}

function updateSuggestions(type) {
    const inputElement = type === 'spacecraft' ? 
        document.getElementById('spacecraftName') : 
        document.getElementById('subsystemName');
    const datalistElement = type === 'spacecraft' ? 
        document.getElementById('spacecraftSuggestions') : 
        document.getElementById('subsystemSuggestions');
    
    const query = inputElement.value.trim();
    if (query.length < 1) { // Changed from 2 to 1 to enable from first letter
        datalistElement.innerHTML = '';
        return;
    }
    
    setLoading(true);
    const xhr = new XMLHttpRequest();
    xhr.open('GET', contextPath + `/getSuggestions.jsp?type=${type}&query=${encodeURIComponent(query)}`, true);
    xhr.timeout = 5000;
    
    xhr.onload = function() {
        setLoading(false);
        if (xhr.status === 200) {
            try {
                const suggestions = JSON.parse(xhr.responseText);
                datalistElement.innerHTML = '';
                suggestions.forEach(suggestion => {
                    const option = document.createElement('option');
                    option.value = suggestion;
                    datalistElement.appendChild(option);
                });
            } catch (e) {
                showStatus('Error parsing suggestions', 'error');
            }
        }
    };
    
    xhr.onerror = function() {
        setLoading(false);
        showStatus('Error fetching suggestions', 'error');
    };
    
    xhr.send();
}

function updateSubsystemSuggestionsForSpacecraft(spacecraftName) {
    if (!spacecraftName) return;
    
    const datalistElement = document.getElementById('subsystemSuggestions');
    
    setLoading(true);
    const xhr = new XMLHttpRequest();
    xhr.open('GET', contextPath + `/getSuggestions.jsp?type=subsystem&spacecraft=${encodeURIComponent(spacecraftName)}`, true);
    xhr.timeout = 5000;
    
    xhr.onload = function() {
        setLoading(false);
        if (xhr.status === 200) {
            try {
                const suggestions = JSON.parse(xhr.responseText);
                datalistElement.innerHTML = '';
                suggestions.forEach(suggestion => {
                    const option = document.createElement('option');
                    option.value = suggestion;
                    datalistElement.appendChild(option);
                });
            } catch (e) {
                showStatus('Error parsing subsystem suggestions', 'error');
            }
        }
    };
    
    xhr.onerror = function() {
        setLoading(false);
        showStatus('Error fetching subsystem suggestions', 'error');
    };
    
    xhr.send();
}

function uploadCSV() {
    const fileInput = document.getElementById('csvFile');
    const file = fileInput.files[0];
    
    if (!file) {
        showStatus('Please select a CSV file first', 'error');
        return;
    }
    
    if (!validateCSVFile(file)) {
        showStatus('Invalid file type. Please upload a CSV file.', 'error');
        return;
    }
    
    setLoading(true);
    const reader = new FileReader();
    
    reader.onload = function(e) {
        try {
            const csvData = e.target.result;
            console.log('File read successfully, length:', csvData.length);
            
            let parsedData = parseCSV(csvData);
            
            if (!parsedData) {
                console.log('Main parser failed, trying simple parser...');
                parsedData = parseCSVSimple(csvData);
                
                if (!parsedData) {
                    console.error('Both parsers failed');
                    showStatus('Error parsing CSV file - no valid data found', 'error');
                    setLoading(false);
                    return;
                }
            }
            
            console.log('CSV parsed successfully, spacecraft name:', parsedData['SpacecraftName']);
            
            const spacecraftName = parsedData['SpacecraftName'] || parsedData['Spacecraft Name'] || parsedData['spacecraft_name'] || 'Unknown';
            const subsystemName = parsedData['SubsystemName'] || parsedData['Subsystem Name'] || parsedData['subsystem_name'] || 'General';
            const pageNo = parsedData['PageNo'] || parsedData['Page No'] || parsedData['pageno'] || 1;
            
            generateUniquePageId(spacecraftName, subsystemName, pageNo, function(pageId) {
                sendCSVData(pageId, parsedData);
            });
        } catch (error) {
            console.error('Error in reader.onload:', error);
            showStatus('Error processing CSV: ' + error.message, 'error');
            setLoading(false);
        }
    };
    
    reader.onerror = function() {
        showStatus('Error reading file', 'error');
        setLoading(false);
    };
    
    reader.readAsText(file);
}

function validateCSVFile(file) {
    const validTypes = ['text/csv', 'application/vnd.ms-excel'];
    const fileName = file.name.toLowerCase();
    const isValid = validTypes.includes(file.type) || fileName.endsWith('.csv');
    console.log('File validation:', {
        name: file.name,
        type: file.type,
        size: file.size,
        isValid: isValid
    });
    return isValid;
}

// Fallback simple CSV parsing if the main parser fails
function parseCSVSimple(csv) {
    console.log('Using simple CSV parser as fallback');
    const lines = csv.split(/\r?\n/).filter(line => line.trim() !== '');
    if (lines.length < 2) return null;
    
    const headers = lines[0].split(',').map(h => h.trim().replace(/^"|"$/g, ''));
    const firstRow = lines[1].split(',').map(v => v.trim().replace(/^"|"$/g, ''));
    
    // Handle case where headers have more columns than data (trailing commas)
    if (headers.length > firstRow.length) {
        console.log('Simple parser: Headers have more columns than data, trimming headers');
        headers.length = firstRow.length;
    } else if (headers.length < firstRow.length) {
        console.log('Simple parser: Data has more columns than headers, trimming data');
        firstRow.length = headers.length;
    }
    
    const data = {};
    headers.forEach((header, i) => {
        data[header] = firstRow[i];
    });
    
    console.log('Simple parser result:', data);
    return data;
}

function parseCSV(csv) {
    console.log('Parsing CSV data...');
    console.log('CSV length:', csv.length);
    console.log('CSV preview:', csv.substring(0, 200));
    
    const lines = csv.split(/\r?\n/).filter(line => line.trim() !== '');
    console.log('Number of lines:', lines.length);
    
    if (lines.length < 2) {
        console.log('Not enough lines in CSV');
        return null;
    }
    // Improved CSV parsing with quoted values support
    function parseCSVLine(line) {
        console.log('Parsing line:', line);
        const result = [];
        let current = '';
        let inQuotes = false;
        
        for (let i = 0; i < line.length; i++) {
            const char = line[i];
            const nextChar = line[i + 1];
            
            if (char === '"') {
                if (inQuotes && nextChar === '"') {
                    // Escaped quote
                    current += '"';
                    i++; // Skip next quote
                } else {
                    // Toggle quote state
                    inQuotes = !inQuotes;
                }
            } else if (char === ',' && !inQuotes) {
                // End of field
                result.push(current.trim());
                current = '';
            } else {
                current += char;
            }
        }
        // Add the last field
        result.push(current.trim());
        console.log('Parsed fields:', result);
        return result;
    }
    const headers = parseCSVLine(lines[0]);
    console.log('Headers:', headers);
    // For bulk CSV upload, we need to process all data rows
    // But for the frontend parsing, we'll just extract basic info from the first row
    if (lines.length > 1) {
        const firstDataRow = parseCSVLine(lines[1]);
        console.log('First data row:', firstDataRow);
        if (!headers || !firstDataRow) {
            console.log('Missing headers or data row');
            return null;
        }
        
        // Handle case where headers have more columns than data (trailing commas)
        if (headers.length > firstDataRow.length) {
            console.log('Headers have more columns than data, trimming headers');
            headers.length = firstDataRow.length;
        } else if (headers.length < firstDataRow.length) {
            console.log('Data has more columns than headers, trimming data');
            firstDataRow.length = headers.length;
        }
        const data = {};
        headers.forEach((header, i) => {
            // Clean header names and map common variations
            let cleanHeader = header.replace(/^"|"$/g, '').trim();
            // Map common variations of field names
            const headerMappings = {
                'spacecraft_name': 'SpacecraftName',
                'spacecraftname': 'SpacecraftName', 
                'name': 'SpacecraftName',
                'subsystem_name': 'SubsystemName',
                'subsystemname': 'SubsystemName',
                'subsystem': 'SubsystemName',
                'record_title': 'RecordTitle',
                'recordtitle': 'RecordTitle',
                'page_no': 'PageNo',
                'pageno': 'PageNo',
                'mission_id': 'Mission ID',
                'missionid': 'Mission ID',
                'launch_date': 'Launch Date',
                'launchdate': 'Launch Date'
            };
            const mappedHeader = headerMappings[cleanHeader.toLowerCase()] || cleanHeader;
            data[mappedHeader] = firstDataRow[i].replace(/^"|"$/g, '').trim();
        });
        console.log('Parsed data:', data);
        return data;
    }
    return null;
}

function generateUniquePageId(spacecraftName, subsystemName, pageNo, callback) {
    // Format: "4 starting letters of spacecraft - 3 starting letters of subsystem - 3 digits page no"
    // Example: "aryabhat" + "power" + "04" = "Arya-pow-004"
    const spacecraftPrefix = (spacecraftName || 'Unkn').substring(0, 4);
    const subsystemPrefix = (subsystemName || 'gen').substring(0, 3).toLowerCase();
    const pageNoStr = pageNo ? pageNo.toString().padStart(3, '0') : '001';
    
    // Capitalize first letter of spacecraft name, keep subsystem lowercase
    const formattedSpacecraft = spacecraftPrefix.charAt(0).toUpperCase() + spacecraftPrefix.slice(1).toLowerCase();
    
    const pageId = `${formattedSpacecraft}-${subsystemPrefix}-${pageNoStr}`;
    
    console.log('Generating Page ID:', {
        spacecraftName: spacecraftName,
        subsystemName: subsystemName,
        pageNo: pageNo,
        formattedSpacecraft: formattedSpacecraft,
        subsystemPrefix: subsystemPrefix,
        pageNoStr: pageNoStr,
        pageId: pageId
    });
    
    const checkUnique = (id, attempts = 0) => {
                            if (attempts > 3) {
                        // Fallback to timestamp-based ID
                        if (callback && typeof callback === 'function') {
                            callback(id + '_' + Date.now().toString().slice(-6));
                        }
                        return;
                    }
        
        const xhr = new XMLHttpRequest();
        xhr.open('GET', contextPath + `/checkPageId.jsp?pageId=${id}`, true);
        
        xhr.onload = function() {
            try {
                if (xhr.status === 200) {
                    const exists = JSON.parse(xhr.responseText).exists;
                                            if (exists) {
                            // If exists, try with incremented page number
                            const newPageNo = parseInt(pageNoStr) + attempts + 1;
                            const newPageId = `${formattedSpacecraft}-${subsystemPrefix}-${newPageNo.toString().padStart(3, '0')}`;
                            checkUnique(newPageId, attempts + 1);
                        } else {
                            if (callback && typeof callback === 'function') {
                                callback(id);
                            }
                        }
                } else {
                    console.error("Error checking page ID: Status " + xhr.status);
                    showStatus("Error checking page ID: " + xhr.statusText, "error");
                    if (callback && typeof callback === 'function') {
                        callback(id); // Fallback if check fails
                    }
                }
            } catch (e) {
                console.error("Error parsing response: ", e);
                if (callback && typeof callback === 'function') {
                    callback(id); // Fallback if check fails
                }
            }
        };
        
        xhr.onerror = function() {
            console.error("Network error checking page ID");
            showStatus("Network error checking page ID", "error");
            if (callback && typeof callback === 'function') {
                callback(id); // Fallback if request fails
            }
        };
        
        xhr.send();
    };
    
    checkUnique(pageId);
}

function sendCSVData(pageId, data) {
    console.log('sendCSVData called with pageId:', pageId, 'data:', data);
    
    const fileInput = document.getElementById('csvFile');
    const file = fileInput.files[0];
    
    if (!file) {
        showStatus('No file selected', 'error');
        setLoading(false);
        return;
    }
    
    // Read the file content as text
    const reader = new FileReader();
    reader.onload = function(e) {
        const csvData = e.target.result;
        
        console.log('CSV Data length:', csvData.length);
        console.log('CSV Data preview:', csvData.substring(0, 200));
        
        // Create URL-encoded form data instead of FormData
        const params = new URLSearchParams();
        params.append('pageId', pageId);
        params.append('spacecraftName', data['SpacecraftName'] || data['Spacecraft Name'] || data['spacecraft_name'] || 'Unknown');
        params.append('subsystemName', data['SubsystemName'] || data['Subsystem Name'] || data['subsystem_name'] || 'General');
        params.append('csvData', csvData);
        
        console.log('Sending parameters:', {
            pageId: pageId,
            spacecraftName: data['SpacecraftName'] || data['Spacecraft Name'] || data['spacecraft_name'] || 'Unknown',
            subsystemName: data['SubsystemName'] || data['Subsystem Name'] || data['subsystem_name'] || 'General'
        });
        
        const xhr = new XMLHttpRequest();
        xhr.open('POST', contextPath + '/uploadCSV.jsp', true);
        xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        xhr.timeout = 10000;
        
        xhr.onload = function() {
            setLoading(false);
            if (xhr.status === 200) {
                try {
                    const response = JSON.parse(xhr.responseText);
                    if (response.success) {
                        showStatus(response.message || 'CSV uploaded successfully!', 'success');
                        
                        // Update total pages and navigation
                        loadTotalPages();
                        
                        // Auto-populate the parameter table with CSV data
                        populateParameterTableFromCSV(data);
                        
                        // Load the newly uploaded record
                        setTimeout(() => {
                            loadRecord(pageId);
                        }, 500);
                        
                    } else {
                        showStatus(response.error || response.message || 'Error uploading CSV', 'error');
                        console.error('Upload error details:', response);
                    }
                } catch (e) {
                    showStatus('Error parsing response: ' + e.message, 'error');
                    console.error('Response parsing error:', e, xhr.responseText);
                }
            } else {
                showStatus('Error uploading CSV: ' + xhr.status + ' ' + xhr.statusText, 'error');
                console.error('Upload HTTP error:', xhr.status, xhr.statusText, xhr.responseText);
            }
        };
        
        xhr.onerror = function() {
            setLoading(false);
            showStatus('Network error during upload', 'error');
            console.error('Network error during upload');
        };
        
        xhr.send(params.toString());
    };
    
    reader.onerror = function() {
        setLoading(false);
        showStatus('Error reading file', 'error');
    };
    
    reader.readAsText(file);
}

function searchRecords() {
    const searchTerm = document.getElementById('searchInput').value.trim();
    if (!searchTerm) {
        showStatus('Please enter a search term', 'warning');
        return;
    }
    
    setLoading(true);
    const xhr = new XMLHttpRequest();
    xhr.open('GET', contextPath + `/searchRecords.jsp?query=${encodeURIComponent(searchTerm)}`, true);
    xhr.timeout = 5000;
    
    xhr.onload = function() {
        setLoading(false);
        if (xhr.status === 200) {
            try {
                const result = JSON.parse(xhr.responseText);
                if (result.pageId) {
                    loadRecord(result.pageId);
                } else {
                    showStatus(result.error || 'No matching records found', 'info');
                }
            } catch {
                showStatus('Error parsing search results', 'error');
            }
        } else {
            showStatus('Search failed: ' + xhr.statusText, 'error');
        }
    };
    
    xhr.onerror = function() {
        setLoading(false);
        showStatus('Search request failed', 'error');
    };
    
    xhr.send();
}

function loadRecord(pageId) {
    if (!pageId) return;
    
    console.log('Loading complete record for PageID:', pageId);
    setLoading(true);
    const xhr = new XMLHttpRequest();
    xhr.open('GET', contextPath + `/getRecord.jsp?pageId=${encodeURIComponent(pageId)}`, true);
    xhr.timeout = 5000;
    
    xhr.onload = function() {
        setLoading(false);
        if (xhr.status === 200) {
            try {
                const record = JSON.parse(xhr.responseText);
                if (record.error) {
                    showStatus(record.error, 'error');
                    return;
                }
                
                currentPageId = record.pageId;
                window.currentPageId = record.pageId; // Sync with global
                currentPageNo = record.pageNo || 1;
                
                console.log('Loading record data:', record);
                console.log('Updated currentPageNo to:', currentPageNo);
                
                // Update UI with Page_Info data
                document.getElementById('pageIdDisplay').textContent = record.pageId || 'N/A';
                document.getElementById('pageNoInput').value = record.pageNo || '';
                document.getElementById('spacecraftName').value = record.spacecraftName || '';
                document.getElementById('subsystemName').value = record.subsystemName || '';
                document.getElementById('recordTitle').value = record.recordTitle || '';
                
                // Load Page_Data parameters into the 38 fields using the correct parameter mapping
                const parameterNames = [
                    "Spacecraft Name", "Mission ID", "Launch Date", 
                    "Orbit Type", "Payload Capacity", "Fuel Capacity", 
                    "Max Thrust", "Engine Type", "Communication Band", 
                    "Power Output", "Solar Array Size", "Battery Capacity", 
                    "Attitude Control", "Navigation System", "Thermal Control", 
                    "Structural Material", "Dry Mass", "Wet Mass", 
                    "Dimensions", "Operational Lifetime", "Data Rate", 
                    "Onboard Storage", "Redundancy Level", "Failure Rate", 
                    "Reliability", "Radiation Tolerance", "Temperature Range", 
                    "Software Version", "Firmware Version", "Autonomy Level", 
                    "Mission Objectives", "Scientific Instruments", "Propulsion System", 
                    "Delta-V Capacity", "Communication Delay", "Ground Stations", 
                    "Mission Cost", "Development Time"
                ];
                
                let paramCount = 0;
                for (let i = 1; i <= 38; i++) {
                    const valueInput = document.getElementById('paramValue' + i);
                    if (valueInput) {
                        const paramName = parameterNames[i - 1];
                        valueInput.value = record[paramName] || '';
                        if (record[paramName]) paramCount++;
                    }
                }
                
                console.log('Loaded ' + paramCount + ' parameters from Page_Data');
                
                // Load custom parameter labels for this spacecraft
                if (typeof loadParameterLabelsInline === 'function') {
                    loadParameterLabelsInline(record.pageId);
                } else {
                    console.log('loadParameterLabelsInline function not available');
                }
                
                showStatus('Record loaded successfully', 'success');
                
                // Update navigation state display
                updateNavigationState();
            } catch (e) {
                console.error('Error parsing record data:', e);
                showStatus('Error parsing record data: ' + e.message, 'error');
            }
        } else {
            showStatus('Error loading record: ' + xhr.statusText, 'error');
        }
    };
    
    xhr.onerror = function() {
        setLoading(false);
        showStatus('Error loading record', 'error');
    };
    
    xhr.send();
}

// Update navigation state display
function updateNavigationState() {
    // This function can be used to update navigation status if needed
    console.log('Navigation state updated');
}

function navigate(direction) {
    console.log('Database navigation:', direction, 'Current page:', currentPageNo);
    console.log('Current PageID:', currentPageId);
    console.log('Page No Input value:', document.getElementById('pageNoInput').value);
    
    // Use the page number from the input field if currentPageNo is not set
    let pageNoToUse = currentPageNo;
    if (!pageNoToUse || pageNoToUse < 1) {
        const inputPageNo = parseInt(document.getElementById('pageNoInput').value, 10);
        if (!isNaN(inputPageNo) && inputPageNo > 0) {
            pageNoToUse = inputPageNo;
            currentPageNo = inputPageNo; // Update the global variable
        } else {
            pageNoToUse = 1; // Default to 1
        }
    }
    
    console.log('Using page number for navigation:', pageNoToUse);
    
    let dbDirection;
    if (direction === 0) dbDirection = 'first';
    else if (direction === -1) dbDirection = 'prev';
    else if (direction === 1) dbDirection = 'next';
    else {
        showStatus('Invalid navigation direction', 'error');
        return;
    }
    
    setLoading(true);
    const xhr = new XMLHttpRequest();
    xhr.open('GET', contextPath + `/getNavigationInfo.jsp?direction=${dbDirection}&currentPageNo=${pageNoToUse}`, true);
    xhr.timeout = 5000;
    
    xhr.onload = function() {
        setLoading(false);
        if (xhr.status === 200) {
            try {
                const result = JSON.parse(xhr.responseText);
                if (result.success && result.navigationInfo.pageId) {
                    const navInfo = result.navigationInfo;
                    const targetPageNo = navInfo.pageNo;
                    const targetPageId = navInfo.pageId;
                    
                    console.log('Database navigation result:', navInfo);
                    
                    // Update current page
                    currentPageNo = targetPageNo;
                    totalPages = result.totalPages;
                    
                    // Update UI
                    document.getElementById('pageNoInput').value = targetPageNo;
                    
                    // Load the record
                    loadRecord(targetPageId);
                    
                    // Update navigation state
                    updateNavigationStateFromDB(result);
                    
                    // Show status
                    const directionText = direction === -1 ? 'Previous' : direction === 1 ? 'Next' : 'First';
                    showStatus(`Navigated to ${directionText} page (${targetPageNo})`, 'success');
                } else {
                    const action = result.navigationInfo.action;
                    if (action === 'prev') {
                        showStatus('Already at the first page', 'info');
                    } else if (action === 'next') {
                        showStatus('Already at the last page', 'info');
                    } else {
                        showStatus('No records available for navigation', 'error');
                    }
                }
            } catch (e) {
                console.error('Error parsing navigation response:', e);
                showStatus('Navigation failed', 'error');
            }
        } else {
            showStatus('Navigation request failed', 'error');
        }
    };
    
    xhr.onerror = function() {
        setLoading(false);
        showStatus('Navigation request failed', 'error');
    };
    
    xhr.send();
}

function saveRecord() {
    // Validate all required fields first
    if (!validateInputs()) {
        return;
    }
    
    const spacecraftName = document.getElementById('spacecraftName').value.trim();
    const subsystemName = document.getElementById('subsystemName').value.trim();
    const pageNoInput = document.getElementById('pageNoInput').value.trim();
    const recordTitle = document.getElementById('recordTitle').value.trim();
    const pageNo = parseInt(pageNoInput, 10);
    
    // Generate pageId if not exists
    if (!currentPageId) {
        generateUniquePageId(spacecraftName, subsystemName, pageNo, function(pageId) {
            currentPageId = pageId;
            window.currentPageId = pageId; // Sync with global
            
            // Immediately update the page ID display
            document.getElementById('pageIdDisplay').textContent = pageId;
            console.log('Generated and displayed new Page ID:', pageId);
            
            // Continue with saving after pageId is generated
            continueSaving();
        });
        return;
    }
    
    continueSaving();
    
    function continueSaving() {
        setLoading(true);
    let params = [];
    params.push('pageId=' + encodeURIComponent(currentPageId));
    params.push('pageNo=' + encodeURIComponent(pageNo));
    params.push('spacecraftName=' + encodeURIComponent(spacecraftName));
    params.push('subsystemName=' + encodeURIComponent(subsystemName));
    params.push('recordTitle=' + encodeURIComponent(recordTitle));
    
    // Collect all 38 parameters using the database column names
    const parameterNames = [
        "Spacecraft Name", "Mission ID", "Launch Date", 
        "Orbit Type", "Payload Capacity", "Fuel Capacity", 
        "Max Thrust", "Engine Type", "Communication Band", 
        "Power Output", "Solar Array Size", "Battery Capacity", 
        "Attitude Control", "Navigation System", "Thermal Control", 
        "Structural Material", "Dry Mass", "Wet Mass", 
        "Dimensions", "Operational Lifetime", "Data Rate", 
        "Onboard Storage", "Redundancy Level", "Failure Rate", 
        "Reliability", "Radiation Tolerance", "Temperature Range", 
        "Software Version", "Firmware Version", "Autonomy Level", 
        "Mission Objectives", "Scientific Instruments", "Propulsion System", 
        "Delta-V Capacity", "Communication Delay", "Ground Stations", 
        "Mission Cost", "Development Time"
    ];
    
    for (let i = 1; i <= 38; i++) {
        const valueInput = document.getElementById('paramValue' + i);
        if (valueInput) {
            const value = valueInput.value.trim();
            const paramName = parameterNames[i - 1];
            // Use URL encoding for parameter names with spaces
            params.push(encodeURIComponent(paramName) + '=' + encodeURIComponent(value));
        }
    }
    const paramString = params.join('&');
    console.log('=== DEBUGGING SAVE PARAMETERS ===');
    console.log('Parameter names array:', parameterNames);
    console.log('Full parameter string:', paramString);
    console.log('=== END DEBUG ===');
    console.log('Required parameters check:');
    console.log('- pageId:', currentPageId);
    console.log('- spacecraftName:', spacecraftName);
    console.log('- subsystemName:', subsystemName);
    console.log('- recordTitle:', recordTitle);
    console.log('- pageNo:', pageNo);
    
    const xhr = new XMLHttpRequest();
    xhr.open('POST', contextPath + '/saveRecord.jsp', true);
    xhr.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
    xhr.timeout = 10000;
    
    xhr.onload = function() {
        setLoading(false);
        if (xhr.status === 200) {
            try {
                const result = JSON.parse(xhr.responseText);
                if (result.success) {
                    showStatus('Record saved successfully!', 'success');
                    currentPageId = result.pageId;
                    window.currentPageId = result.pageId; // Sync with global
                    if (result.pageNo) {
                        currentPageNo = result.pageNo;
                        document.getElementById('pageNoInput').value = result.pageNo;
                    }
                    document.getElementById('pageIdDisplay').textContent = result.pageId;
                    
                    // Save parameter labels after record is saved
                    if (typeof saveParameterLabelsInline === 'function') {
                        setTimeout(function() {
                            console.log('Auto-saving parameter labels after record save...');
                            saveParameterLabelsInline();
                        }, 1000);
                    }
                    
                    // Apply any pending parameter labels
                    if (typeof window.applyPendingParameterLabels === 'function') {
                        setTimeout(function() {
                            window.applyPendingParameterLabels(result.pageId);
                        }, 1200);
                    }
                    
                    // Navigation will work automatically with database queries
                } else {
                    showStatus(result.error || 'Error saving record', 'error');
                }
            } catch {
                showStatus('Error parsing save response', 'error');
            }
        } else {
            console.log('Save failed with status:', xhr.status);
            console.log('Response text:', xhr.responseText);
            try {
                const errorResult = JSON.parse(xhr.responseText);
                showStatus('Save failed: ' + (errorResult.error || xhr.statusText), 'error');
            } catch {
                showStatus('Save failed: ' + xhr.statusText, 'error');
            }
        }
    };
    
    xhr.onerror = function() {
        setLoading(false);
        showStatus('Save request failed', 'error');
    };
    
    xhr.send(paramString);
    }
}

function validateInputs() {
    // Validate spacecraft name (required)
    const spacecraftName = document.getElementById('spacecraftName').value.trim();
    if (!spacecraftName) {
        showStatus('Spacecraft name is required', 'error');
        return false;
    }
    if (spacecraftName.length > 100) {
        showStatus('Spacecraft name must be 100 characters or less', 'error');
        return false;
    }
    
    // Validate subsystem name (required)
    const subsystemName = document.getElementById('subsystemName').value.trim();
    if (!subsystemName) {
        showStatus('Subsystem name is required', 'error');
        return false;
    }
    if (subsystemName.length > 100) {
        showStatus('Subsystem name must be 100 characters or less', 'error');
        return false;
    }
    
    // Validate record title (required)
    const recordTitle = document.getElementById('recordTitle').value.trim();
    if (!recordTitle) {
        showStatus('Record title is required', 'error');
        return false;
    }
    if (recordTitle.length > 200) {
        showStatus('Record title must be 200 characters or less', 'error');
        return false;
    }
    
    // Validate page number (required)
    const pageNoInput = document.getElementById('pageNoInput').value.trim();
    if (!pageNoInput) {
        showStatus('Page number is required', 'error');
        return false;
    }
    
    const pageNo = parseInt(pageNoInput, 10);
    if (isNaN(pageNo) || pageNo < 1) {
        showStatus('Page number must be a positive integer', 'error');
        return false;
    }
    
    return true;
}

function deleteRecord() {
    if (!currentPageId) {
        showStatus('No record loaded to delete', 'error');
        return;
    }
    
    if (!confirm('Are you sure you want to delete this record? This action cannot be undone.')) {
        return;
    }
    
    setLoading(true);
    const xhr = new XMLHttpRequest();
    xhr.open('POST', contextPath + '/deleteRecord.jsp', true);
    xhr.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
    xhr.timeout = 5000;
    
    xhr.onload = function() {
        setLoading(false);
        if (xhr.status === 200) {
            try {
                const result = JSON.parse(xhr.responseText);
                if (result.success) {
                    showStatus('Record deleted successfully', 'success');
                    resetForm();
                    // Navigation will work automatically with database queries
                } else {
                    showStatus(result.error || 'Error deleting record', 'error');
                }
            } catch {
                showStatus('Error parsing delete response', 'error');
            }
        } else {
            showStatus('Delete failed: ' + xhr.statusText, 'error');
        }
    };
    
    xhr.onerror = function() {
        setLoading(false);
        showStatus('Delete request failed', 'error');
    };
    
    xhr.send(`pageId=${encodeURIComponent(currentPageId)}`);
}

function resetForm() {
    currentPageId = null;
    currentPageNo = 1; // Reset to 1 instead of 0
    totalPages = 0;
    document.getElementById('pageIdDisplay').textContent = 'N/A';
    document.getElementById('pageNoInput').value = '';
    document.getElementById('spacecraftName').value = '';
    document.getElementById('subsystemName').value = '';
    document.getElementById('recordTitle').value = '';
    
    // Reset all 38 parameter fields
    for (let i = 1; i <= 38; i++) {
        const labelInput = document.getElementById(`paramLabel${i}`);
        const valueInput = document.getElementById(`paramValue${i}`);
        
        if (labelInput && valueInput) {
            labelInput.value = '';
            valueInput.value = '';
        }
    }
}

function showStatus(message, type) {
    const statusElement = document.getElementById('statusMessage');
    if (!statusElement) return;
    
    statusElement.textContent = message;
    statusElement.className = type;
    
    // Auto-hide success messages after 5 seconds
    if (type === 'success') {
        setTimeout(() => {
            if (statusElement.textContent === message) {
                statusElement.textContent = '';
                statusElement.className = '';
            }
        }, 5000);
    }
}

function getParameterName(index) {
    const parameterNames = [
        "", // Index 0 unused
        "Spacecraft Name", "Mission ID", "Launch Date", "Orbit Type", 
        "Payload Capacity", "Fuel Capacity", "Max Thrust", "Engine Type", 
        "Communication Band", "Power Output", "Solar Array Size", 
        "Battery Capacity", "Attitude Control", "Navigation System", 
        "Thermal Control", "Structural Material", "Dry Mass", "Wet Mass", 
        "Dimensions", "Operational Lifetime", "Data Rate", "Onboard Storage", 
        "Redundancy Level", "Failure Rate", "Reliability", "Radiation Tolerance", 
        "Temperature Range", "Software Version", "Firmware Version", 
        "Autonomy Level", "Mission Objectives", "Scientific Instruments", 
        "Propulsion System", "Delta-V Capacity", "Communication Delay", 
        "Ground Stations", "Mission Cost", "Development Time"
    ];
    return parameterNames[index] || "Parameter " + index;
}

// Function to populate parameter table from CSV data
function populateParameterTableFromCSV(csvData) {
    // Update spacecraft and subsystem name fields
    const spacecraftNameInput = document.getElementById('spacecraftName');
    const subsystemNameInput = document.getElementById('subsystemName');
    
    if (csvData['Spacecraft Name'] || csvData['spacecraft_name']) {
        spacecraftNameInput.value = csvData['Spacecraft Name'] || csvData['spacecraft_name'];
    }
    if (csvData['Subsystem Name'] || csvData['subsystem_name']) {
        subsystemNameInput.value = csvData['Subsystem Name'] || csvData['subsystem_name'];
    }
    
    // Populate parameter fields
    for (let i = 1; i <= 38; i++) {
        const paramName = getParameterName(i);
        const inputElement = document.getElementById(`param${i}`);
        
        if (inputElement && csvData[paramName]) {
            inputElement.value = csvData[paramName];
        }
    }
    
    showStatus('Parameter table populated from CSV data', 'success');
}

// Function to export current page details to CSV
function exportToCSV() {
    const spacecraftName = document.getElementById('spacecraftName').value.trim();
    const subsystemName = document.getElementById('subsystemName').value.trim();
    const recordTitle = document.getElementById('recordTitle').value.trim();
    const pageNo = document.getElementById('pageNoInput').value.trim();
    
    if (!spacecraftName || !subsystemName) {
        showStatus('Spacecraft Name and Subsystem Name are required for CSV export', 'error');
        return;
    }
    
                        // Collect all parameter data from the current page
                    const csvData = [];
                    const headers = ['RecordTitle', 'PageNo', 'SpacecraftName', 'SubsystemName', 'PageID'];
                    const values = [recordTitle || '', pageNo || '', spacecraftName, subsystemName, currentPageId || ''];
    
    // Add all parameters from the parameter table
    for (let i = 1; i <= 38; i++) {
        const labelInput = document.getElementById(`paramLabel${i}`);
        const valueInput = document.getElementById(`paramValue${i}`);
        
        if (labelInput && valueInput) {
            const label = labelInput.value.trim();
            const value = valueInput.value.trim();
            
            if (label) {
                headers.push(label);
                values.push(value);
            }
        }
    }
    
    // Create CSV content
    const csvContent = headers.join(',') + '\n' + values.map(value => {
        // Escape commas and quotes in values
        if (value.includes(',') || value.includes('"') || value.includes('\n')) {
            return '"' + value.replace(/"/g, '""') + '"';
        }
        return value;
    }).join(',');
    
    // Download CSV file
    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    
    if (link.download !== undefined) {
        const url = URL.createObjectURL(blob);
        link.setAttribute('href', url);
        link.setAttribute('download', `${spacecraftName}_${subsystemName}_page${pageNo}.csv`);
        link.style.visibility = 'hidden';
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        
        showStatus('Current page exported to CSV successfully', 'success');
    } else {
        showStatus('CSV export not supported in this browser', 'error');
    }
}

function exportAll() {
    // Export all data from the database
    console.log('Starting export all...');
    setLoading(true);
    
    const xhr = new XMLHttpRequest();
    xhr.open('GET', contextPath + '/exportAll.jsp', true);
    xhr.timeout = 30000; // 30 seconds timeout for large exports
    
    xhr.onload = function() {
        setLoading(false);
        console.log('Export all response status:', xhr.status);
        console.log('Export all response length:', xhr.responseText.length);
        console.log('Export all response preview:', xhr.responseText.substring(0, 200));
        
        if (xhr.status === 200) {
            try {
                const response = xhr.responseText;
                
                // Check if response is CSV data (starts with header)
                if (response.startsWith('RecordTitle,PageNo,SpacecraftName,SubsystemName')) {
                    console.log('Valid CSV response detected, downloading...');
                    // Download CSV file
                    const blob = new Blob([response], { type: 'text/csv;charset=utf-8;' });
                    const link = document.createElement('a');
                    
                    if (link.download !== undefined) {
                        const url = URL.createObjectURL(blob);
                        link.setAttribute('href', url);
                        link.setAttribute('download', 'all_spacecraft_data.csv');
                        link.style.visibility = 'hidden';
                        document.body.appendChild(link);
                        link.click();
                        document.body.removeChild(link);
                        
                        showStatus('All data exported to CSV successfully', 'success');
                    } else {
                        showStatus('CSV export not supported in this browser', 'error');
                    }
                } else {
                    console.log('Response is not CSV, trying to parse as JSON error...');
                    // Try to parse as JSON error response
                    try {
                        const result = JSON.parse(response);
                        showStatus(result.error || 'Error exporting all data', 'error');
                    } catch {
                        showStatus('Error exporting all data - invalid response format', 'error');
                    }
                }
            } catch (e) {
                console.error('Error processing export response:', e);
                showStatus('Error processing export response', 'error');
            }
        } else {
            console.error('Export failed with status:', xhr.status, xhr.statusText);
            showStatus('Export failed: ' + xhr.statusText, 'error');
        }
    };
    
    xhr.onerror = function() {
        setLoading(false);
        showStatus('Export request failed', 'error');
    };
    
    xhr.ontimeout = function() {
        setLoading(false);
        showStatus('Export request timed out', 'error');
    };
    
    xhr.send();
}

// Function to auto-save changes to CSV when parameters are modified
function setupAutoSyncToCSV() {
    // Add event listeners to all parameter inputs
    for (let i = 1; i <= 38; i++) {
        const inputElement = document.getElementById(`param${i}`);
        if (inputElement) {
            inputElement.addEventListener('change', function() {
                if (currentPageId) {
                    // Debounce the auto-save to avoid too frequent updates
                    clearTimeout(inputElement.autoSaveTimeout);
                    inputElement.autoSaveTimeout = setTimeout(() => {
                        autoSaveToCSV();
                    }, 2000); // Save 2 seconds after user stops typing
                }
            });
        }
    }
    
    // Add listeners to spacecraft and subsystem name fields
    document.getElementById('spacecraftName').addEventListener('change', function() {
        if (currentPageId) {
            clearTimeout(this.autoSaveTimeout);
            this.autoSaveTimeout = setTimeout(() => {
                autoSaveToCSV();
            }, 2000);
        }
    });
    
    document.getElementById('subsystemName').addEventListener('change', function() {
        if (currentPageId) {
            clearTimeout(this.autoSaveTimeout);
            this.autoSaveTimeout = setTimeout(() => {
                autoSaveToCSV();
            }, 2000);
        }
    });
}

// Function to automatically update CSV file when parameters change
function autoSaveToCSV() {
    if (!currentPageId) return;
    
    const spacecraftName = document.getElementById('spacecraftName').value.trim();
    if (!spacecraftName) return;
    
    // Send updated data to server to update CSV
    const params = new URLSearchParams();
    params.append('pageId', currentPageId);
    params.append('action', 'updateCSV');
    params.append('spacecraftName', spacecraftName);
    params.append('subsystemName', document.getElementById('subsystemName').value.trim());
    
    // Add all parameter values
    for (let i = 1; i <= 38; i++) {
        const paramName = getParameterName(i);
        const inputElement = document.getElementById(`param${i}`);
        const value = inputElement ? inputElement.value.trim() : '';
        params.append(paramName, value);
    }
    
    const xhr = new XMLHttpRequest();
    xhr.open('POST', contextPath + '/updateCSV.jsp', true);
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    
    xhr.onload = function() {
        if (xhr.status === 200) {
            try {
                const response = JSON.parse(xhr.responseText);
                if (response.success) {
                    console.log('CSV auto-updated successfully');
                    // Show a subtle indication that auto-save happened
                    const statusElement = document.getElementById('statusMessage');
                    if (statusElement && !statusElement.textContent) {
                        statusElement.textContent = 'Auto-saved to CSV';
                        statusElement.className = 'success';
                        setTimeout(() => {
                            if (statusElement.textContent === 'Auto-saved to CSV') {
                                statusElement.textContent = '';
                                statusElement.className = '';
                            }
                        }, 2000);
                    }
                }
            } catch (e) {
                console.error('Error parsing auto-save response:', e);
            }
        }
    };
    
    xhr.send(params.toString());
}

function scheduleAutoSync() {
    if (autoSyncTimeout) {
        clearTimeout(autoSyncTimeout);
    }
    
    autoSyncTimeout = setTimeout(() => {
        autoSyncToCSV();
    }, 1000); // 1 second delay for auto-save
}

// Enhanced Search Functionality
let searchTimeout = null;
let selectedSuggestionIndex = -1;
let currentSuggestions = [];

function handleSearchInput() {
    const searchInput = document.getElementById('searchInput');
    const query = searchInput.value.trim();
    
    // Clear previous timeout
    if (searchTimeout) {
        clearTimeout(searchTimeout);
    }
    
    if (query.length < 2) {
        hideSearchSuggestions();
        return;
    }
    
    // Debounce search requests
    searchTimeout = setTimeout(() => {
        fetchSearchSuggestions(query);
    }, 300);
}

function fetchSearchSuggestions(query) {
    const xhr = new XMLHttpRequest();
    xhr.open('GET', contextPath + `/getSmartSuggestions.jsp?query=${encodeURIComponent(query)}`, true);
    xhr.timeout = 5000;
    
    xhr.onload = function() {
        if (xhr.status === 200) {
            try {
                const suggestions = JSON.parse(xhr.responseText);
                displaySearchSuggestions(suggestions);
            } catch (e) {
                console.error('Error parsing suggestions:', e);
                hideSearchSuggestions();
            }
        } else {
            hideSearchSuggestions();
        }
    };
    
    xhr.onerror = function() {
        hideSearchSuggestions();
    };
    
    xhr.send();
}

function displaySearchSuggestions(suggestions) {
    const suggestionsContainer = document.getElementById('searchSuggestions');
    currentSuggestions = suggestions;
    selectedSuggestionIndex = -1;
    
    if (!suggestions || suggestions.length === 0) {
        suggestionsContainer.innerHTML = '<div class="search-no-results">No suggestions found</div>';
        suggestionsContainer.style.display = 'block';
        return;
    }
    
    let html = '';
    suggestions.forEach((suggestion, index) => {
        if (suggestion.error) {
            return;
        }
        
        html += `
            <div class="search-suggestion" data-index="${index}" onclick="selectSuggestion(${index})">
                <span class="suggestion-icon">${suggestion.icon || '🔍'}</span>
                <div class="suggestion-text">
                    <div><strong>${suggestion.text}</strong></div>
                    <small>${suggestion.description || ''}</small>
                </div>
                <span class="suggestion-type">${suggestion.type}</span>
            </div>
        `;
    });
    
    suggestionsContainer.innerHTML = html;
    suggestionsContainer.style.display = 'block';
}

function hideSearchSuggestions() {
    const suggestionsContainer = document.getElementById('searchSuggestions');
    suggestionsContainer.style.display = 'none';
    selectedSuggestionIndex = -1;
}

function handleSearchKeyNavigation(e) {
    const suggestionsContainer = document.getElementById('searchSuggestions');
    
    if (suggestionsContainer.style.display !== 'block') {
        return;
    }
    
    const suggestions = suggestionsContainer.querySelectorAll('.search-suggestion');
    
    if (e.key === 'ArrowDown') {
        e.preventDefault();
        selectedSuggestionIndex = Math.min(selectedSuggestionIndex + 1, suggestions.length - 1);
        updateSuggestionSelection(suggestions);
    } else if (e.key === 'ArrowUp') {
        e.preventDefault();
        selectedSuggestionIndex = Math.max(selectedSuggestionIndex - 1, -1);
        updateSuggestionSelection(suggestions);
    } else if (e.key === 'Enter' && selectedSuggestionIndex >= 0) {
        e.preventDefault();
        selectSuggestion(selectedSuggestionIndex);
    } else if (e.key === 'Escape') {
        hideSearchSuggestions();
    }
}

function updateSuggestionSelection(suggestions) {
    suggestions.forEach((suggestion, index) => {
        suggestion.classList.toggle('selected', index === selectedSuggestionIndex);
    });
}

function selectSuggestion(index) {
    if (index < 0 || index >= currentSuggestions.length) {
        return;
    }
    
    const suggestion = currentSuggestions[index];
    const searchInput = document.getElementById('searchInput');
    
    searchInput.value = suggestion.text;
    hideSearchSuggestions();
    
    // Automatically search for the selected suggestion
    searchRecords();
}

// Enhanced search records function
function searchRecords() {
    const searchTerm = document.getElementById('searchInput').value.trim();
    if (!searchTerm) {
        showStatus('Please enter a search term', 'warning');
        return;
    }
    
    hideSearchSuggestions();
    setLoading(true);
    
    console.log('Searching for:', searchTerm);
    
    const xhr = new XMLHttpRequest();
    xhr.open('GET', contextPath + `/searchRecords.jsp?query=${encodeURIComponent(searchTerm)}`, true);
    xhr.timeout = 10000;
    
    xhr.onload = function() {
        setLoading(false);
        if (xhr.status === 200) {
            try {
                const result = JSON.parse(xhr.responseText);
                console.log('Search result:', result);
                
                if (result.pageId) {
                    console.log('Loading record with PageID:', result.pageId);
                    loadRecord(result.pageId);
                    showStatus(`Found record: ${searchTerm}`, 'success');
                } else {
                    showStatus(result.error || 'No matching records found', 'info');
                }
            } catch (e) {
                console.error('Error parsing search results:', e);
                showStatus('Error parsing search results', 'error');
            }
        } else {
            showStatus('Search failed: ' + xhr.statusText, 'error');
        }
    };
    
    xhr.onerror = function() {
        setLoading(false);
        showStatus('Search request failed', 'error');
    };
    
    xhr.ontimeout = function() {
        setLoading(false);
        showStatus('Search request timed out', 'error');
    };
    
    xhr.send();
}

// Debug function to check navigation state
function debugNavigation() {
    console.log('=== Database Navigation Debug Info ===');
    console.log('Current Page ID:', currentPageId);
    console.log('Current Page No:', currentPageNo);
    console.log('Total Pages:', totalPages);
    console.log('=============================');
}

function updateNavigationStateFromDB(navigationResult) {
    // Update page number input to reflect current state
    document.getElementById('pageNoInput').value = currentPageNo;
    
    // Update navigation buttons state
    const prevBtn = document.querySelector('button[onclick="navigate(-1)"]');
    const nextBtn = document.querySelector('button[onclick="navigate(1)"]');
    
    if (prevBtn && nextBtn) {
        // Enable/disable buttons based on database result
        prevBtn.disabled = !navigationResult.hasPrevious;
        nextBtn.disabled = !navigationResult.hasNext;
        
        // Update button tooltips to show current position
        if (navigationResult.totalPages > 0) {
            prevBtn.title = `Previous page (${navigationResult.currentPosition}/${navigationResult.totalPages})`;
            nextBtn.title = `Next page (${navigationResult.currentPosition}/${navigationResult.totalPages})`;
        }
        
        // Log navigation state for debugging
        console.log(`Database navigation state: Page ${navigationResult.currentPosition}/${navigationResult.totalPages} (Page No: ${currentPageNo})`);
    }
}

function goToPage() {
    const pageNo = parseInt(document.getElementById('pageNoInput').value, 10);
    if (isNaN(pageNo) || pageNo < 1) {
        showStatus('Please enter a valid page number.', 'error');
        return;
    }
    
    console.log('Go to page requested:', pageNo, 'Current page:', currentPageNo);
    
    // Check if we're already on this page
    if (pageNo === currentPageNo) {
        showStatus(`Already on page ${pageNo}`, 'info');
        return;
    }
    
    setLoading(true);
    const xhr = new XMLHttpRequest();
    xhr.open('GET', contextPath + `/getNavigationInfo.jsp?direction=goto&currentPageNo=${pageNo}`, true);
    xhr.timeout = 5000;
    
    xhr.onload = function() {
        setLoading(false);
        if (xhr.status === 200) {
            try {
                const result = JSON.parse(xhr.responseText);
                if (result.success && result.navigationInfo.pageId) {
                    const navInfo = result.navigationInfo;
                    const targetPageNo = navInfo.pageNo;
                    const targetPageId = navInfo.pageId;
                    
                    console.log('Go to page result:', navInfo);
                    
                    // Update current page
                    currentPageNo = targetPageNo;
                    totalPages = result.totalPages;
                    
                    // Load the record
                    loadRecord(targetPageId);
                    
                    // Update navigation state
                    updateNavigationStateFromDB(result);
                    
                    showStatus(`Navigated to page ${pageNo}`, 'success');
                } else {
                    showStatus(`No record found for page ${pageNo}`, 'error');
                }
            } catch (e) {
                console.error('Error parsing go to page response:', e);
                showStatus('Error parsing response.', 'error');
            }
        } else {
            showStatus('Failed to fetch record.', 'error');
        }
    };
    
    xhr.onerror = function() {
        setLoading(false);
        showStatus('Request failed.', 'error');
    };
    
    xhr.send();
}

```

## 3. css/style.css

*Complete CSS file with all styling:*

```css
body {
    font-family: Arial, sans-serif;
    margin: 0;
    padding: 0;
    background-color: #f0f0f0;
}

.container {
    display: flex;
    height: 100vh;
}

.left-panel {
    width: 20%;
    padding: 20px;
    background-color: #e0e0e0;
    overflow-y: auto;
}

.right-panel {
    width: 80%;
    padding: 50px;
    background-color: #ffff;
    overflow-y: auto;
}

.input-group {
    margin-bottom: 15px;
}

.input-group label {
    display: block;
    margin-bottom: 5px;
    font-weight: bold;
}

.input-group input {
    width: 100%;
    padding: 8px;
    border: 1px solid #ccc;
    border-radius: 4px;
}

.csv-upload, .search-box, .help-section {
    margin-top: 30px;
    padding: 15px;
    background-color: #f5f5f5;
    border-radius: 5px;
}

.csv-upload h3, .search-box h3 {
    margin-top: 0;
}

button {
    padding: 8px 15px;
    background-color: #4CAF50;
    color: white;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    margin-top: 10px;
}

button:hover {
    background-color: #45a049;
}

.delete-btn {
    background-color: #f44336;
}

.delete-btn:hover {
    background-color: #d32f2f;
}

.export-btn {
    background-color: #2196F3;
}

.export-btn:hover {
    background-color: #1976D2;
}

#csvFile {
    width: 100%;
    padding: 8px 0;
}

.page-info {
    display: flex;
    justify-content: space-between;
    margin-bottom: 15px;
    font-weight: bold;
    align-items: center;
}

.action-buttons {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 15px;
}

.left-buttons {
    display: flex;
    gap: 10px;
}

.right-buttons {
    display: flex;
    gap: 10px;
}

.action-buttons button {
    padding: 8px 15px;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-size: 14px;
    font-weight: 500;
}

.save-btn {
    background-color: #4CAF50;
    color: white;
}

.save-btn:hover {
    background-color: #45a049;
}

.delete-btn {
    background-color: #f44336;
    color: white;
}

.delete-btn:hover {
    background-color: #d32f2f;
}

.export-btn {
    background-color: #2196F3;
    color: white;
}

.export-btn:hover {
    background-color: #1976D2;
}

.export-all-btn {
    background-color: #FF9800;
    color: white;
}

.export-all-btn:hover {
    background-color: #F57C00;
}

.navigation {
    margin-bottom: 15px;
}

.navigation button {
    margin-right: 10px;
}

#parameterTable {
    width: 80%;
    margin-left: auto;
    margin-right: 0;
    background-color: black;
    border-collapse: collapse;
}

#parameterTable td {
    padding: 8px;
    border: 1px solid #444;
}

.param-label {
    color: white;
    text-align: left;
    width: 60%;
}

.param-value {
    background-color: white;
    width: 20%;
}

.param-input {
    width: 100%;
    padding: 5px;
    border: 1px solid #ccc;
}



#statusMessage {
    margin-top: 15px;
    padding: 10px;
    border-radius: 4px;
}

.success {
    background-color: #dff0d8;
    color: #3c763d;
}

.error {
    background-color: #f2dede;
    color: #a94442;
}
```
