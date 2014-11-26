/*******************************************************************************
* Copyright (c) 2013 GigaSpaces Technologies Ltd. All rights reserved
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*       http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*******************************************************************************/
import java.util.concurrent.TimeUnit
import java.util.UUID
import org.openspaces.admin.AdminFactory
import org.openspaces.admin.application.config.ApplicationConfig
import org.openspaces.admin.pu.config.ProcessingUnitConfig
import org.openspaces.admin.space.SpaceDeployment
import groovy.text.SimpleTemplateEngine
import org.openspaces.core.gateway.GatewayTarget
import org.openspaces.admin.space.Space
import java.util.regex.Pattern

def puname=args[0]
def spacename=args[1]
def zones=args[2]
def locallocators=args[3]
def localgwname=args[4]
def targets=args[5]
def sources=args[6]
def lookups=Eval.me(quoteAlnum(args[7]))
def natmappings=args[8] //map from private to public ip

assert (spacename!=null),"space name must not be null"
assert (locallocators!=null),"no local locators"
assert (localgwname!=null),"local gateway name must not be null"
assert (lookups!=null),"no lookups defined"

//CREATE PU
pudir="/tmp/gwpu/META-INF/spring"
new AntBuilder().sequential(){
	delete(dir:pudir)
	mkdir(dir:pudir)
}

def binding=[:]
binding['localgwname']=localgwname
binding['localspaceurl']="jini://*/*/${spacename}?locators=${locallocators}"
binding['lookups']=lookups
binding['targets']=targets
binding['sources']=sources

def engine = new SimpleTemplateEngine()
def putemplate = new File('/tmp/gateway-pu.xml')
def template = engine.createTemplate(putemplate).make(binding)
new File("${pudir}/pu.xml").withWriter{ out->
	out.write(template.toString())
}

if(natmappings!=null && natmappings.size()>0){
   def nm=natmappings.trim().split(",")
   new File("/tmp/network_mapping.config").withPrintWriter{out ->
	for(int i=0;i<nm.size();i+=2){
		out.println "${nm[i]},${nm[i+1]}"
	}
   }
}

//DEPLOY

// find gsm
def admin=new AdminFactory().useDaemonThreads(true).addLocators(locallocators).createAdmin();
def gsm=admin.gridServiceManagers.waitForAtLeastOne(1,TimeUnit.MINUTES)
assert gsm!=null

// Make sure the space exists
Space space=admin.getSpaces().waitFor(spacename,1,TimeUnit.MINUTES)
assert space!=null,"failed to locate space ${spacename}"

//deploy
def pucfg=new ProcessingUnitConfig()
pucfg.setProcessingUnit("/tmp/gwpu")
pucfg.setName(puname)
pucfg.addZone(zones) //only deploy to this gsc

def pu=gsm.deploy(pucfg,1,TimeUnit.MINUTES)

assert pu!=null,"timed out waiting for gateway deployment"

// add gateway to space
targets.trim().split(",").each{target->
	//remove existing, if any
	try{
	  space.getReplicationManager().removeGatewayTarget(target)
  	}
	catch(exc){}
	println "adding target ${target}"
	GatewayTarget gwTarget = new GatewayTarget(target)
	space.getReplicationManager().addGatewayTarget(gwTarget)
}

//Puts quotes around alpha-num substrings in parameter

def static quoteAlnum(unquoted){
   def p=Pattern.compile('([a-zA-Z0-9_\\-\\.]+)')
   def m=p.matcher(unquoted)
   return m.replaceAll("\"\$1\"")
}

