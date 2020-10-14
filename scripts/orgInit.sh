sfdx force:org:create -a PEReliability -f ./config/project-scratch-def.json -d 2 -w 10 -s
sfdx force:source:push -u PEReliability
sfdx force:user:permset:assign -u PEReliability -n ServiceRequestManager
sfdx force:data:tree:import -p ./data/Plan.json
sfdx force:org:open -u PEReliability
