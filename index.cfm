<cfscript>
function mainMenu() {
    writeOutput("
        <h1>Personal Finance Tracker</h1>
        <form action='index.cfm' method='post'>
            <p>1. Add a new transaction</p>
            <p>2. View transactions and summary within a date range</p>
            <p>3. Exit</p>
            <input type='hidden' name='action' value='mainMenu'>
            <label for='choice'>Enter your choice (1-3):</label>
            <input type='text' id='choice' name='choice' required>
            <input type='submit' value='Submit'>
        </form>
    ");
}

function addTransactionForm() {
    writeOutput("
        <form action='index.cfm' method='post'>
            <input type='hidden' name='action' value='addTransaction'>
            <label for='date'>Enter the date of the transaction (dd-mm-yyyy) or leave blank for today's date:</label>
            <input type='text' id='date' name='date'>
            <br>
            <label for='amount'>Enter the amount:</label>
            <input type='text' id='amount' name='amount' required>
            <br>
            <label for='category'>Enter the category ('I' for Income or 'E' for Expense):</label>
            <input type='text' id='category' name='category' required>
            <br>
            <label for='description'>Enter a description (optional):</label>
            <input type='text' id='description' name='description'>
            <br>
            <input type='submit' value='Submit'>
        </form>
    ");
}

function viewTransactionsForm() {
    writeOutput("
        <form action='index.cfm' method='post'>
            <input type='hidden' name='action' value='viewTransactions'>
            <label for='startDate'>Enter the start date (dd-mm-yyyy):</label>
            <input type='text' id='startDate' name='startDate' required>
            <br>
            <label for='endDate'>Enter the end date (dd-mm-yyyy):</label>
            <input type='text' id='endDate' name='endDate' required>
            <br>
            <input type='submit' value='Submit'>
        </form>
    ");
}

function addTransaction() {
    var dataEntryComponent = createObject("component", "data_entry");
    var date = dataEntryComponent.getDate(FORM.date, true);
    var amount = dataEntryComponent.getAmount(FORM.amount);
    var category = dataEntryComponent.getCategory(FORM.category);
    var description = dataEntryComponent.getDescription(FORM.description);

    function addEntry(date, amount, category, description) {
        var newEntry = date & "," & amount & "," & category & "," & description & chr(13) & chr(10);
        writeOutput("Adding entry to CSV file...");
        fileAppend("finance_data.csv", newEntry, "UTF-8");
        writeOutput("Entry added successfully");
    }

    addEntry(date, amount, category, description);
}

function viewTransactions() {
    var dataEntryComponent = createObject("component", "data_entry");
    var startDate = dataEntryComponent.getDate(FORM.startDate, false);
    var endDate = dataEntryComponent.getDate(FORM.endDate, false);

    function isValidDate(dateStr) {
        try {
            parseDateTime(dateStr, "dd-mm-yyyy");
            return true;
        } catch (any e) {
            return false;
        }
    }

    function getTransactions(startDate, endDate) {
        var fileContent = fileRead("finance_data.csv", "UTF-8");
        var rows = listToArray(fileContent, chr(10));
        var transactions = [];

        for (var i = 1; i <= arrayLen(rows); i++) {
            var columns = listToArray(rows[i], ",");
            if (i == 1 && columns[1] == "date") { // Skip header row
                continue;
            }
            if (isValidDate(columns[1])) {
                var transactionDate = parseDateTime(columns[1], "dd-mm-yyyy");

                if (transactionDate >= parseDateTime(startDate, "dd-mm-yyyy") AND transactionDate <= parseDateTime(endDate, "dd-mm-yyyy")) {
                    arrayAppend(transactions, {
                        date: columns[1],
                        amount: columns[2],
                        category: columns[3],
                        description: columns[4]
                    });
                }
            }
        }

        if (arrayLen(transactions) == 0) {
            writeOutput("No transactions found in the given date range.");
        } else {
            writeOutput("Transactions from " & dateFormat(startDate, "dd-mm-yyyy") & " to " & dateFormat(endDate, "dd-mm-yyyy") & "<br>");
            writeOutput("<table border='1'><tr><th>Date</th><th>Amount</th><th>Category</th><th>Description</th></tr>");

            for (var j = 1; j <= arrayLen(transactions); j++) {
                writeOutput("<tr><td>" & transactions[j].date & "</td><td>" & transactions[j].amount & "</td><td>" & transactions[j].category & "</td><td>" & transactions[j].description & "</td></tr>");
            }

            writeOutput("</table>");

            var totalIncome = 0;
            var totalExpense = 0;

            for (var k = 1; k <= arrayLen(transactions); k++) {
                if (transactions[k].category == "Income") {
                    totalIncome += transactions[k].amount;
                } else if (transactions[k].category == "Expense") {
                    totalExpense += transactions[k].amount;
                }
            }

            writeOutput("<br>Total Income: $" & totalIncome);
            writeOutput("<br>Total Expense: $" & totalExpense);
            writeOutput("<br>Net Savings: $" & (totalIncome - totalExpense));
        }
    }

    getTransactions(startDate, endDate);
}

function main() {
    if (NOT structKeyExists(FORM, "action")) {
        mainMenu();
    } else {
        switch (FORM.action) {
            case "mainMenu":
                switch (FORM.choice) {
                    case "1":
                        addTransactionForm();
                        break;
                    case "2":
                        viewTransactionsForm();
                        break;
                    case "3":
                        writeOutput("Exiting...");
                        break;
                    default:
                        writeOutput("Invalid choice. Enter 1, 2, or 3.");
                        mainMenu();
                        break;
                }
                break;
            case "addTransaction":
                addTransaction();
                break;
            case "viewTransactions":
                viewTransactions();
                break;
            default:
                mainMenu();
                break;
        }
    }
}

main();
</cfscript>
