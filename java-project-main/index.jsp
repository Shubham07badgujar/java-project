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