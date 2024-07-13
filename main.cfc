<cfscript>
    // Define constants
    CSV_FILE = "finance_data.csv";
    COLUMNS = ["date", "amount", "category", "description"];
    FORMAT = "dd-mm-yyyy";

    // Initialize CSV file if it doesn't exist
    if (!fileExists(CSV_FILE)) {
        writeOutput("Creating CSV file...");
        csvWrite(CSV_FILE, COLUMNS, true);
    }

    // Define a function to add a new entry to the CSV file
    function addEntry(date, amount, category, description) {
        var newEntry = {
            "date" = date,
            "amount" = amount,
            "category" = category,
            "description" = description
        };
        writeOutput("Adding entry to CSV file...");
        csvWrite(CSV_FILE, newEntry, true);
        writeOutput("Entry added successfully");
    }

    // Define a function to get transactions within a date range
    function getTransactions(startDate, endDate) {
        var df = csvRead(CSV_FILE);
        df.date = parseDateTime(df.date, FORMAT);
        startDate = parseDateTime(startDate, FORMAT);
        endDate = parseDateTime(endDate, FORMAT);

        var filteredDF = queryNew("");
        filteredDF = queryAddRow(filteredDF, df);
        filteredDF = queryFilter(filteredDF, "date >= #startDate# AND date <= #endDate#");

        if (filteredDF.recordCount EQ 0) {
            writeOutput("No transactions found in the given date range.");
        } else {
            writeOutput("Transactions from " & dateFormat(startDate, FORMAT) & " to " & dateFormat(endDate, FORMAT));
            writeOutput(queryToTable(filteredDF));

            var totalIncome = querySum(filteredDF, "amount", "category = 'Income'");
            var totalExpense = querySum(filteredDF, "amount", "category = 'Expense'");
            writeOutput("Total Income: $" & totalIncome);
            writeOutput("Total Expense: $" & totalExpense);
            writeOutput("Net Savings: $" & (totalIncome - totalExpense));
        }
        
        return filteredDF;
    }

    // Define a function to plot transactions (to be implemented)
    function plotTransactions(df) {
        // Implement plotting functionality using a suitable ColdFusion chart library
    }

    // Main program logic
    var dataEntryComponent = createObject("component", "data_entry");
    var choice = "";
    while (choice NEQ "3") {
        writeOutput("1. Add a new transaction<br>");
        writeOutput("2. View transactions and summary within a date range<br>");
        writeOutput("3. Exit<br>");
        choice = input("Enter your choice (1-3): ");
        
        if (choice == "1") {
            var date = dataEntryComponent.getDate("Enter the date of the transaction (dd-mm-yyyy) or enter for today's date: ", true);
            var amount = dataEntryComponent.getAmount();
            var category = dataEntryComponent.getCategory();
            var description = dataEntryComponent.getDescription();
            addEntry(date, amount, category, description);
        } else if (choice == "2") {
            var startDate = dataEntryComponent.getDate("Enter the start date (dd-mm-yyyy): ");
            var endDate = dataEntryComponent.getDate("Enter the end date (dd-mm-yyyy): ");
            var df = getTransactions(startDate, endDate);
            if (input("Do you want to see a plot? (y/n) ") EQ "y") {
                plotTransactions(df);
            }
        } else if (choice == "3") {
            writeOutput("Exiting...");
        } else {
            writeOutput("Invalid choice. Enter 1, 2 or 3.");
        }
    }
</cfscript>
