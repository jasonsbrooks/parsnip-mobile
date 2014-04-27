// Custom assertion function. Asserts that condition is true, else error logs message.
function assert(condition, message) {
    if (!condition) {
		UIALogger.logError(message);
    }
}

assert(1 == 1, "Equality fail: 1 == 2");

var testName = "UITest1";
var target = UIATarget.localTarget();
var app = target.frontMostApp();
var window = app.mainWindow();

// Log test name and element tree.
UIALogger.logStart(testName);
app.logElementTree();

var navBar = app.navigationBar();
var tabBar = app.tabBar();

// Show element trees for both navBar and tabBar.
navBar.logElementTree();
tabBar.logElementTree();

// Assert that navigation bar and tab bar have the correct number of elements.
assert(navBar.buttons().length === 1,
	   "Incorrect number of UINavBar buttons on load.");
assert(navBar.staticTexts().length === 1,
	   "Incorrect number of UINavBar static texts on load.");
assert(tabBar.buttons().length === 3,
	   "Incorrect number of UITabBar buttons on load.");

assert(navBar.staticTexts()[0].name() == "Store Info", "Error");

// Stay on same tab and assert 
tabBar.buttons()[0].tap();
assert(navBar.staticTexts()[0].name() == "Store Info", "Error");

// Press the deals tab.
tabBar.buttons()[1].tap();
navBar = UIATarget.localTarget().frontMostApp().mainWindow().navigationBar();
UIALogger.logMessage("Logging deals window element tree.");
navBar.logElementTree();
assert(navBar.staticTexts().length === 1,
	   "Incorrect number of static texts in deals window.");
assert(navBar.staticTexts()[0].name() === "All Deals",
	   "Deals window doesn't display 'All Deals'.");

// Determine that deals are valid
// ...

// Press the customer help tab.
tabBar.buttons()[2].tap();
navBar = UIATarget.localTarget().frontMostApp().mainWindow().navigationBar();
UIALogger.logMessage("Logging customer help window element tree.");
navBar.logElementTree();
assert(navBar.staticTexts().length === 1,
	   "Incorrect number of static texts in customer help window.");
assert(navBar.staticTexts()[0].name() === "Help",
	   "Help window doesn't display 'Help'.");


// Save screenshot of final state
UIATarget.localTarget().captureScreenWithName("UITest1_result_screen");

