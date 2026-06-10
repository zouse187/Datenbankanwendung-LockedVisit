<?php
// config/db.php

function db_connect($username, $password) {
    // host:port/service_name
    $connStr = "rs03-db-inf-min.ad.fh-bielefeld.de:1521/orcl.rs03-db-inf-min.ad.fh-bielefeld.de";

    $conn = @oci_connect($username, $password, $connStr, 'AL32UTF8');

    if (!$conn) {
        $e = oci_error();
        return ['success' => false, 'error' => $e['message']];
    }

    return ['success' => true, 'conn' => $conn];
}
