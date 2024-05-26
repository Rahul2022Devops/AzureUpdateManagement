# AzureUpdateManagement

#do not it require any azure monitoring agent in this case?


You're correct. Azure Update Management leverages the Azure Monitor Log Analytics service to collect data and perform update management tasks, but it doesn't require a separate agent installation on the virtual machines.

When you enable Update Management for your virtual machines through Azure Update Management, it automatically installs the required agent (the Microsoft Monitoring Agent) on the virtual machines. This agent collects data from the virtual machines and sends it to the Log Analytics workspace for analysis.

Therefore, in the Terraform configuration provided earlier, there's no need to explicitly install a monitoring agent on the virtual machines. The association between the virtual machines and Azure Update Management handles the agent installation and data collection automatically.
