<%@ page isErrorPage="true" %>
<!DOCTYPE html>
<html>
<head>
    <title>Error - Spacecraft App</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #181818;
            color: #fff;
            padding: 40px;
            text-align: center;
        }
        .error-container {
            background: #222;
            padding: 30px;
            border-radius: 8px;
            max-width: 600px;
            margin: 0 auto;
        }
        .error-code {
            font-size: 3em;
            color: #f44336;
            margin-bottom: 20px;
        }
        .error-message {
            font-size: 1.2em;
            margin-bottom: 20px;
        }
        .back-link {
            display: inline-block;
            margin-top: 20px;
            padding: 10px 20px;
            background: #4CAF50;
            color: white;
            text-decoration: none;
            border-radius: 4px;
        }
        .back-link:hover {
            background: #45a049;
        }
    </style>
</head>
<body>
    <div class="error-container">
        <div class="error-code">
            <%= request.getAttribute("javax.servlet.error.status_code") != null ? 
                request.getAttribute("javax.servlet.error.status_code") : "Error" %>
        </div>
        <div class="error-message">
            <% 
            Integer statusCode = (Integer) request.getAttribute("javax.servlet.error.status_code");
            if (statusCode != null) {
                if (statusCode == 404) {
                    out.println("Page Not Found");
                } else if (statusCode == 500) {
                    out.println("Internal Server Error");
                } else {
                    out.println("An error occurred");
                }
            } else {
                out.println("An unexpected error occurred");
            }
            %>
        </div>
        <p>We're sorry, but something went wrong. Please try again or contact support if the problem persists.</p>
        <a href="${pageContext.request.contextPath}/" class="back-link">Go Back to Home</a>
    </div>
</body>
</html>
