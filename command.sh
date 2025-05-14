deployment: func azure functionapp publish rtpipeline-fn --python
confirmation of deployment : az resource show --resource-group arahiqi --name rtpipeline-fn --resource-type Microsoft.Web/sites
Get process_reviews / slack_notification URL : az functionapp function show --resource-group arahiqi --name rtpipeline-fn --function-name process_reviews --query invokeUrlTemplate --output tsv
Deploy Logic Apps: az logic workflow create --resource-group arahiqi --name rtpipeline-logic-app --definition logic_apps/workflow.json
slack_notification Function Key: az functionapp function keys list --resource-group arahiqi --name rtpipeline-fn --function-name slack_notification --query "default" --output tsv
delete the curent workflow : az logic workflow delete --resource-group arahiqi --name rtpipeline-logic-app --yes