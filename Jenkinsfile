pipeline {

  agent any

environment {

      sonar_url = 'http://10.1.1.18:9000'
      sonar_username = 'admin'
      sonar_password = 'admin#sonar#123'
      nexus_url = '35.222.210.226:8081'
      artifact_version = '0.0.1'

 }
  options {
    buildDiscarder(logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '2', numToKeepStr: '10'))
    ansiColor('xterm')
    disableConcurrentBuilds()
  }


  tools {
    jdk 'JAVA8'
    maven 'Maven-3.3'

  }


  parameters {
      string(defaultValue: 'discovery-service', description: 'COC Service name', name: 'Service')
      string(defaultValue: 'master', description: 'COC branch to build', name: 'Branch')
      choice(
        name: 'Cluster',
        choices: ['gke_cognitive-genie-63754_us-central1-a_rapid-istio'],
        description: 'Cluster you want to deploy the pod to' )

  }


  stages {
    stage ('Cleanup Workspace') {
      steps {
        cleanWs()
        }
      }
    stage ('Checkout Codebase') {
        steps {
          echo "====== Current WORKSPACE Directory is ${env.WORKSPACE} ======="
          echo "============== GIT Source Code Branch: ${Branch} =============="
          checkout(
            [
              $class: 'GitSCM',
              branches: [[name: '${Branch}']],
              doGenerateSubmoduleConfigurations: false,
              extensions: [
                [$class: 'CleanBeforeCheckout'],
                [$class: 'CloneOption', depth: 0, noTags: false, reference: '', shallow: false, timeout: 120],
                [$class: 'CheckoutOption', timeout: 120],
                [$class: 'CleanBeforeCheckout'],
                [$class: 'CleanCheckout'],
                [$class: 'PruneStaleBranch']
                ],
                submoduleCfg: [],
                userRemoteConfigs: [
                  [
                    credentialsId: '5a2a0d63-2d2c-4bb0-94a0-db4dc740f911',
                    url: 'https://pscode.lioncloud.net/commerceoncloud/${Service}.git'
                    ]
                  ]
                ],
              )
          }
        }
     stage ('Build and Compile Codebase') {
        steps {
          sh '''
          mvn clean install -U -Dmaven.test.skip=true
          mvn -f ${WORKSPACE}/ clean install checkstyle:checkstyle findbugs:findbugs pmd:pmd pmd:cpd cobertura:cobertura -Dcobertura.report.format=xml
          '''
        }
      }
    stage ('adding check for API contract testing'){
         steps{
          script{
              if (fileExists ("${WORKSPACE}/src/test/resources/contracts/**/*.groovy" )) {
              currentBuild.result = 'CONTINUE'
              }else{
              currentBuild.result = 'ABORTED'
              print "Please add APIContract testing files"
             }
           }
         }
       }
     
     stage ('Sonarqube Analysis'){
           steps {
           withSonarQubeEnv('SonarQube') {
           sh '''
           mvn clean package org.jacoco:jacoco-maven-plugin:prepare-agent install -Dmaven.test.failure.ignore=false
           mvn -e -B sonar:sonar -Dsonar.java.source=1.8 -Dsonar.host.url="${sonar_url}" -Dsonar.login="${sonar_username}" -Dsonar.password="${sonar_password}" -Dsonar.sourceEncoding=UTF-8
           '''
           }
         }
      }
     stage("Quality Gate") {

         steps {
              sleep(30)
              script {
               def qualitygate = waitForQualityGate()
               if (qualitygate.status != "OK") {
               error "Pipeline aborted due to quality gate failure: ${qualitygate.status}"
               }
              }
            }
          }
    /* stage ('Publish Artifact') {
        steps {
          nexusArtifactUploader artifacts: [[artifactId: '${Service}', classifier: '', file: "target/${Service}-${env.artifact_version}.jar", type: 'jar']], credentialsId: 'ca1d8e48-50b5-46c5-ba0c-7762f4403926', groupId: 'com.sapient.mc', nexusUrl: "${nexus_url}", nexusVersion: 'nexus3', protocol: 'http', repository: 'releases', version: "${artifact_version}"
        }
      }
      stage ('Archive Artifact') {
        steps {
          archiveArtifacts '**/*.jar'
        }
      }/*
      stage ('Build Docker Image'){
        steps {
          sh '''
          cd ${WORKSPACE}
          docker build -t gcr.io/cognitive-genie-63754/COC_${Service} --file=src/main/docker/Dockerfile ${WORKSPACE}
          '''
        }
      }
      stage ('Publish Docker Image'){
        steps {
          sh '''
          docker push gcr.io/cognitive-genie-63754/COC_${Service}:latest
          '''
        }
      }
      stage ('CleanUp Docker Image'){
        steps {
          sh '''
          if [ `docker images --format '{{.Repository}}' | grep "mesh_${Service}" | wc -l` -gt 0 ]; then
echo "INFO => removing local docker images for mesh_${Service}, please wait..."
docker rmi -f `docker images --format '{{.Repository}} {{.ID}}' | grep "mesh_${Service}" | cut -f2 -d ' ' | uniq`
fi
          '''
        }
      }
      stage ('Deploy to kubernetes'){
        steps{
          script {

          if ( env.cluster == 'gke_cognitive-genie-63754_us-central1-a_rapid-istio'){
          try{
            sh "kubectl config use-context ${Cluster}"
       sh "export PATH=/home/jenkins/istio-1.0.5/bin:$PATH"
     sh "cd ${WORKSPACE}"
     sh "kubectl delete -f '${WORKSPACE}'/src/main/kube/deployment.yml"
     sh "kubectl apply -f '${WORKSPACE}'/src/main/kube/service.yml"
     sh "kubectl apply -f '${WORKSPACE}'/src/main/kube/deployment.yml"
     sh "kubectl apply -f '${WORKSPACE}'/src/main/networking/config-gateway.yml"

            }catch (Exception e) {

         sh "kubectl apply -f '${WORKSPACE}'/src/main/kube/service.yml"
         sh "kubectl apply -f '${WORKSPACE}'/src/main/kube/deployment.yml"
         sh "kubectl apply -f '${WORKSPACE}'/src/main/networking/config-gateway.yml"
     }
            }
            else {
            try{
               sh "kubectl config use-context ${Cluster}"
               sh "cd ${WORKSPACE}"
               sh "kubectl delete -f '${WORKSPACE}'/src/main/kube/deployment.yml"
        sh "kubectl apply -f  '${WORKSPACE}'/src/main/kube/service.yml"
        sh "kubectl apply -f '${WORKSPACE}'/src/main/kube/deployment.yml"
               }catch (Exception e) {

         sh "kubectl apply -f '${WORKSPACE}'/src/main/kube/service.yml"
         sh "kubectl apply -f '${WORKSPACE}'/src/main/kube/deployment.yml"
         sh "kubectl apply -f '${WORKSPACE}'/src/main/networking/config-gateway.yml"
     }

          }
        }
       }
      }


  }
}
