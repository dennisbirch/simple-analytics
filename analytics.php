<?php
/*
Here is an example script written in PHP for handling the output from SimpleAnalytics on a 
web service that hosts MySQL databases. Please consider this as a starting point, or an 
inspiration for your own solution.

CAVEAT EMPTOR: This script was created by a relatively new PHP programmer, using documentation
and solutions found online. It may have serious unknown flaws as it has only been lightly 
tested. But it has been found to work in at least light usage. As always, your mileage may vary.

===============

This script assumes a MySQL database with tables for "items" and "counters", where...
...the 'items' table's columns are:
description: VarChar
details: VarChar
device_id: VarChar
app_name: VarChar
app_version: VarChar
platform: VarChar
id: Auto incrementing primary key


...the 'counters' table's columns are:
description: VarChar
count: Integer
device_id: VarChar
app_name: VarChar
app_version: VarChar
platform: VarChar
id: Auto incrementing primary key

****************
Be sure to configure the following four properties in order to be able to connect to your database.
****************
*/
$database_servername = "";
$database_name = "";
$username = "";
$password = "";

$dbErrorCode = 503;

$body = @file_get_contents('php://input');

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
	echo(generateErrorResponse($conn->connect_error, $dbErrorCode));
	return;
}

parse_body($body, $conn);

function parse_body($body, $conn) {
	$body_string = (string)$body;
	$decoded = json_decode($body_string);

	$items = $decoded->items;
    $counters = $decoded->counters;	

	$device_id = (string)$decoded->device_id;
    $application = (string)$decoded->app_name;
	$app_version = (string)$decoded->app_version;
    $platform = (string)$decoded->platform;
    $system_version = (string)$decoded->system_version;

	$currentCount = 0;
	
	// add 'items' array contents to database
	if (count($items) > 0 ) {
		$description = "";
		$details = "";
		$timestamp = "";
	
			// prepare and bind items insert statement
		$prepared = $stmt = $conn->prepare("INSERT INTO items (description, details, device_id, app_name, app_version, platform, system_version, timestamp) VALUES (?, ?, ?, ?, ?, ?, ?, ?);");
		if ($prepared === false) {
			echo(generateErrorResponse("Error preparing 'items' insert statement", $dbErrorCode));
			return;
		}

		$stmt->bind_param("ssssssss", $description, $details, $device_id, $application, $app_version, $platform, $system_version, $timestamp);

		
		foreach ($items as $item) {
			// set parameters and execute
			$description = (string)$item->description;
			$title = (string)$item->description;
			$details = stdObject_array_toString($item->parameters);
			$timestamp = (string)$item->timestamp;

			if ($stmt->execute() === true) {
				$currentCount += 1;
			}				
		}
	}

	// add 'counters' array contents to database
	if (count($counters) > 0) {
		$name = "";
		$itemCount = 0;
		$timestamp = "";

		// prepare and bind counters insert statement
		$prepared = $stmt = $conn->prepare("INSERT INTO counters (description, count, device_id, app_name, app_version, platform, system_version, timestamp) VALUES (?, ?, ?, ?, ?, ?, ?, ?);");
		if ($prepared === false) {
			echo(generateErrorResponse("Error preparing 'counters' insert statement", $dbErrorCode));
			return;
		}

		$stmt->bind_param("sdssssss", $name, $itemCount, $device_id, $application, $app_version, $platform, $system_version, $timestamp);
		
			
		foreach ($counters as $item) {
			// set parameters and execute
			$name = (string)$item->name;
			$itemCount = (int)$item->count;
			$timestamp = (string)$item->timestamp;
		
			if ($stmt->execute() === true) {
				$currentCount += 1;
			}				
		}
	}	

	$conn->close();
	
	$success['message'] = 'Successfully added ' . $currentCount . ' items to the Analytics database.';

	$encoded = json_encode($success);
	echo((string)$encoded);
}

function stdObject_array_toString($array) {
	// convert the 'parameters' dictionary contents to a string for insertion in the database
	// https://stackoverflow.com/questions/2537767/how-to-convert-a-php-object-to-a-string
	if ($array === null) { return ""; }
	
	$r = new ReflectionObject($array);
	return '{' . implode(', ', array_map(
     function($p) use ($array) {
         $p->setAccessible(true);
         return $p->getName() .': '. $p->getValue($array);
     }, $r->getProperties())) .'}';
}

function generateErrorResponse($message, $code) {
	header ($message, true, $code);	

	$response = array('message' => $message);
	$encoded = json_encode($response);
	
	return (string)$encoded;
}

?>
