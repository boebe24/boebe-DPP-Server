# FA³ST Server Deployment Guide

![Static Badge](https://img.shields.io/badge/Java_JDK-21-blue)

![Static Badge](https://img.shields.io/badge/FA%C2%B3ST_Service_Starter-1.0.1-darkgreen?link=https%3A%2F%2Ffaaast-service.readthedocs.io%2Fen%2Flatest%2Findex.html)



## Introduction

This project provides step-by-step guidance on deploying a FA³ST server on your VPS (Virtual Private Server) with a custom domain. The server can be used in conjunction with the FA³ST project client or our boebeapp.

Before starting, you'll need to:
1. Purchase a domain
2. Set up your keystore and truststore files with passwords

Please read the [FA³ST documentation](https://faaast-service.readthedocs.io/en/latest/basics/usage.html) before proceeding.

## Project Structure

### `productsDPPs.json`

This file contains the Digital Product Passport(s) (DPP(s)) for your product(s). To work with [our boebe-DPP-Viewer app](https://github.com/boebe24/boebe-DPP-Viewer)
, each DPP should include the following submodels:

| Submodel IdShort   | Template Source | Content |
|---------------------|------------------|---------|
| DigitalNameplate    | [Digital Nameplate Template](https://github.com/admin-shell-io/submodel-templates/tree/main/published/Digital%20nameplate/2/0) | Product Name (idShort: ManufacturerProductDesignation), Product Type (idShort: ManufacturerProductType), Manufacturer Name (idShort: ManufacturerName), etc. |
| CarbonFootprint     | [Carbon Footprint Template](https://github.com/admin-shell-io/submodel-templates/tree/main/published/Carbon%20Footprint) | Carbon footprint information |
| Images              | N/A | Files, each containing a URL to an image |

#### Important Notice: Sample Data

> **Disclaimer:** The data contained in `productsDPPs.json` is provided solely as a sample to help users understand the usage and structure of the DPP (Digital Product Passport) format.
> All of the 
> - weight measurements
> - Carbon footprint amounts
> - Contact information
> - Other product details
>
>  are **fictional** and do not correspond to any real-world products or entities. This sample data is intended for demonstration and educational purposes only.

For more details on the Asset Administration Shell format, refer to the [Plattform Industrie 4.0 documentation](https://www.plattform-i40.de/IP/Redaktion/DE/Downloads/Publikation/Details_of_the_Asset_Administration_Shell_Part_2_V1.pdf?__blob=publicationFile&v=8).

Recommended tools for editing AAS:
- [AASX Package Explorer](https://github.com/admin-shell-io/aasx-package-explorer) (Windows, Archived)
- [Eclipse AASPE](https://github.com/eclipse-aaspe/package-explorer) (Windows, New)

### `config.json`

This is a template configuration file for using a JKS-format keystore for the server. Please refer to the [FA³ST configuration documentation](https://faaast-service.readthedocs.io/en/latest/basics/configuration.html) for more information.

Key points:
- Choose a port for the FA³ST service (e.g., 453). This will affect the endpoint URL.
- Set up your keystore file details:
  ```json
  "certificate": {
      "keyStoreType": "JKS",
      "keyStorePath": "./data/mykeystore.jks",
      "keyStorePassword": "mystorepass",
      "keyAlias": "mykeyalias",
      "keyPassword": "mykeypass"
  }
  ```
  Replace `mykeystore.jks`, `mystorepass`, `mykeyalias`, and `mykeypass` with your actual values.

### `killandrun.sh`

This script restarts the FA³ST service on a specified port. It performs the following actions:
1. Kills the process running on the specified port
2. Searches for the first JSON file in the specified directory containing the DPP keyword
3. Runs the FA³ST starter with the found model, logging output to `faaast{PORT_NUMBER}Output.log`
4. Prompts you to check the firewall

Usage:
Set the correct `PORT_NUMBER` at the beginning of the script. Other variables can remain unchanged if you're using the default file structure.

## Deployment Guide

This guide extends the [official FA³ST usage documentation](https://faaast-service.readthedocs.io/en/latest/basics/usage.html), providing additional context for those unfamiliar with the process.

### 1. Obtain a Unix-based VPS

You should receive:
- At least one IPv4 or IPv6 address
- Username (e.g., root)
- Password for login

Example: `123.456.789.123`

> Note: Our team tested this project on a VPS with an Intel Xeon CPU, Ubuntu 22.04 x64, 1TB RAM, located in Frankfurt. AMD CPUs have not been tested.

### 2. Purchase a Domain

You should receive:
- A domain that you own and can add DNS records to

Example: `boebe2024tech.top`

> This domain is used as an example in our tutorial. Please replace it with your own in the following steps.

> Tip: Consider using a platform like Cloudflare for domain purchase, as it may simplify SSL certificate application. Ensure your domain registrar hides your contact information (check using [who.is](https://who.is/)).

### 3. Create DNS Records for Your Domain

Add DNS records to point your domain to your VPS IP address. This process may take hours to take effect, so do this step early.

To test:
- Windows: Open CMD and run `ping boebe2024tech.top` and `ping www.boebe2024tech.top`
- Mac: Open Terminal and run the same commands

### 4. Apply for an SSL Certificate for Your Domain

Follow the instructions from your chosen Certificate Authority. You'll typically receive:
- `certificate.crt`
- `private.key`
- `ca_bundle.crt`

> Note: FA³ST doesn't require uploading certificates to `/etc/ssl/` or configuring Apache. Focus on validating domain ownership to receive the certificate.

### 5. Set Up Java JDK

Install Java 17+ on your VPS:

For Ubuntu/Debian-based systems:
```bash
apt update
apt install openjdk-21-jdk
```

Verify installation with `java -version`.

### 6. Convert SSL Certificate to Java Keystore/Truststore

Generate:
- `keyStore.jks` using `certificate.crt` and `private.key` (for the server)
- `trustStore.jks` using `ca_bundle.crt` (for the client)
- `boebe_bundle.pem` using `ca_bundle.crt` (for Android clients)

Use `keytool` in the terminal or a GUI tool like [Keystore Explorer](https://keystore-explorer.org/downloads.html).

Example keystore setup in `config.json`:
```json
"certificate": {
    "keyStoreType": "JKS",
    "keyStorePath": "./data/mykeystore.jks",
    "keyStorePassword": "mystorepass",
    "keyAlias": "mykeyalias",
    "keyPassword": "mykeypass"
}
```

### 7. Upload Files to the Server

Upload the following to your VPS:
- `starter-{version}.jar` (download from the [official FA³ST website](https://faaast-service.readthedocs.io/en/latest/basics/installation.html))
- `/data/` folder containing:
  - `config.json`
  - Keystore (`.jks` file)
  - Model file (`.aasx` or `.json`)

Example directory structure:
```
/root/faaast453/
├── starter-1.0.1.jar
├── killandrun.sh
├── data/
│   ├── config.json
│   ├── productsDPPS.json
│   └── mykeystore.jks
```

### 8. Start the FA³ST Service

Run the `killandrun.sh` script:
```bash
cd /root/faaast453/
./killandrun.sh
```

For debugging, add `-v`, `-vv`, or `-vvv` options for more detailed output.

You should receive an endpoint string, including the port number.

Example endpoints:
- `https://www.boebe2024tech.top:443/api/v3.0/`
- `https://www.boebe2024tech.top:473/api/v3.0/`

Helpful Unix commands for managing ports and firewalls:
```bash
# Firewall management
sudo ufw enable
sudo ufw status
sudo ufw allow 453
sudo ufw allow 463

# Check port availability
sudo ss -tuln | grep :443
sudo lsof -i :443

# Kill process by PID
kill 21000
```

### 9. Test SSL

Use [SSL Checker](https://www.sslshopper.com/ssl-checker.html) to verify your SSL certificate. Enter your endpoint URL (e.g., `https://www.xxxx.top:443/api/v3.0/`).

### 10. Test from Browsers or Postman

Access your endpoint with "/submodels" appended in a browser or send a GET request via Postman:

Examples:
- `https://www.boebe2024tech.top:453/api/v3.0/submodels/`
- `https://www.boebe2024tech.top:473/api/v3.0/submodels/`

For more details on URL patterns, refer to the [Plattform Industrie 4.0 documentation](https://www.plattform-i40.de/IP/Redaktion/DE/Downloads/Publikation/Details_of_the_Asset_Administration_Shell_Part_2_V1.pdf?__blob=publicationFile&v=8).

## Client-Side Guide

To communicate with a running server as a client, you'll need:

1. Endpoint(s) for each DPP (starting with "https://" and including a port number)
2. `.jks` file for trustStore with password (for Java apps)
3. `.pem` file for trustStore (for Android apps)

### Setting Up Trust Certificate in Java (non-Android)

Add the truststore file to your client app and configure Java to use it:

```java
private static void trustMyCertificate() {
    System.setProperty("javax.net.ssl.trustStore", "./data/mytruststore.jks");
    System.setProperty("javax.net.ssl.trustStorePassword", "mytrustpass");
}
```

Replace the path, filename, and password as needed.

You can then use FA³ST methods with these endpoints:

```java
private static final String SERVICE_ENDPOINT_BT_ROBOT = "https://www.boebe2024tech.top:443/api/v3.0";
private static final String SERVICE_ENDPOINT_BT_SMARTPHONE = "https://www.boebe2024tech.top:453/api/v3.0";
```

### Setting Up Trust Certificate for Android Apps

1. Place the `.pem` file in the `res/raw/` directory (e.g., `mycertificates.pem`)

2. Create a network security configuration file at `res/xml/network_security_config.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <!-- is HTTP allowed or not-->
    <base-config cleartextTrafficPermitted="false">
        <trust-anchors>
            <!-- Trust system certificates -->
            <certificates src="system"/>
            <!-- Trust our self-signed certificates  -->
            <certificates src="@raw/mycertificates"/>
        </trust-anchors>
    </base-config>
</network-security-config>
```

### Explanation of network_security_config.xml

The line `<certificates src="system"/>` imports existing certificates stored in the system of the smartphone as a **trust-anchor**.

If you are hosting a FA³ST server:
- You do not need each DPP-viewer app to include a pem file from you in their source code.
- Instead, ensure your server has an SSL certificate recognized by Google.
- The line `<certificates src="@raw/mycertificates"/>` is not necessary in this case.

If you are a developer of a DPP-viewer Android app:
- You can add the pem into the system certificates.
- The `mycertificates.pem` file and relevant settings (`<certificates src="@raw/mycertificates"/>`) are not necessary.

  
3. Add the following to your `AndroidManifest.xml` file:

```xml
android:networkSecurityConfig="@xml/network_security_config"
```

> Note: This network configuration affects all network communications in your app. Images in the DPP might fail to display if their URLs lack trusted certificates.

For alternative solutions of network configuration, refer to the [Android developer documentation on network security configuration](https://developer.android.com/privacy-and-security/security-config).
