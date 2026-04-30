<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>Bulk Import / Export</title>
</head>
<body>

<div class="container" style="max-width:600px; margin-top:40px;">

    <h2>Bulk Location Import</h2>

    <g:uploadForm controller="bulkLocation" action="importCsv">
        <div style="margin-bottom:16px;">
            <label><b>Upload CSV file:</b></label><br/>
            <input type="file" name="file" accept=".csv" style="margin-top:8px;"/>
        </div>

        <button type="submit" class="btn btn-primary">
            Import CSV
        </button>
    </g:uploadForm>

    <hr style="margin-top:40px;"/>

    <h2>Export Only (no import)</h2>
    <p>Export all existing locations in the database as a decrypted Excel file.</p>
    <g:link controller="bulkLocation" action="exportExcel" class="btn btn-default">
        Download Decrypted Excel
    </g:link>

</div>

</body>
</html>