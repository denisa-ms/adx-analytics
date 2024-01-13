# Workshop - Building an Analytics platform using Azure Data Explorer 
Created by: [Denise Schlesinger](https://www.linkedin.com/in/deniseschlesinger/)

# Introduction
Suppose you own an e-commerce website selling bike accessories.  
You have millions of visitors a month, you want to analyze the website traffic, consumer patterns and predict sales.  
This workshop will walk you through the process of building an end-to-end Data Analytics Solution for your e-commerce website.

You will learn how to:
* Build a star schema in Azure Data Explorer
* Build Data pipelines using Azure Data Factory for CDC (change data capture)
* Stream events into Azure Event hubs and ingest them into Azure Data Explorer
* Create data transformations in Azure Data Explorer 
* Use Notebooks to create product recommendations
* Create reports & Visualize the data using Power BI
* Create reports and Alerts connecting Grafana to Azure Data Explorer

## Workshop sections
[Introduction](#introduction)  
[Pre-requisites](#pre-requisites)  
[Build the infrastructure](#building-the-infrastructure)  
[Joining with external tables](#joining-with-external-tables)  
[Ingesting events into Azure Data Explorer from Event hub](#ingesting-events-into-azure-data-explorer-from-event-hub)  
[CDC using Azure Data Factory](#cdc-using-azure-data-factory)  
[Create synthetic events with orders](#create-synthetic-events-with-orders)  
[Visualization in Azure Data Explorer web UI](#visualization-in-azure-data-explorer-web-ui)  
[Visualization in PowerBI](#visualization-in-power-bi)  
[Visualization and alerts in Grafana](visualization-and-alerts-in-grafana)  
[Materialized views](#materialized-views)  
[ML in Azure Data Explorer](#ml-in-azure-data-explorer)  
[Monitoring](#monitoring)
[Additional information](#additional-information)

## Architecture
![Architectural Diagram](./images/architecture.png)

## Pre-requisites
* An Azure Account where you have admin permissions
* Python 3.7 running locally in your machine
* VsCode

# Building the infrastructure
## Run scripts to build all the Infrastructure
Modify userId in the grafana bicep 
Run powershell
# Joining with External tables
# Ingesting events into Azure Data Explorer from Event hub
# CDC using Azure Data Factory
# Create synthetic events with orders
# Visualization in Azure Data Explorer web UI
# Visualization in PowerBI
# Visualization and alerts in Grafana
# Materialized views
# ML in Azure Data Explorer

# Monitoring 
Setup diagnostic logs  
https://learn.microsoft.com/en-us/azure/data-explorer/using-diagnostic-logs?tabs=ingestion

Create an Azure alert on FailedIngestion table   
https://learn.microsoft.com/en-us/azure/azure-monitor/alerts/tutorial-log-alert


# Additional Information
How to configure an app registration to connect to Azure Data Explorer  
https://learn.microsoft.com/en-us/azure/data-explorer/provision-entra-id-app


Add AAD user from another tenant to access from PBI to ADX  
.add database ['storeDB'] admins ("aaduser=user@microsoft.com;your aad tenant id here")

Jaccard Similarity   
https://www.geeksforgeeks.org/how-to-calculate-jaccard-similarity-in-python/

Add AAD app to ADX as admin + run the following command inside ADX   
.add database ['your db name'] users ('aadapp=your app-id') 'Demo app put your comment here (AAD)'

