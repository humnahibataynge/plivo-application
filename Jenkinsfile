// Stages:
//     Build
//     Unit-test
//     Docker tag and upload
//     helm update
//     helm deploy

// write a jenkins pipeline in declarative mode that will contain below steps:
// Stages:
//     Checkout the code: Checkout the code from github repo
//     Build: Build the docker image
//     Unit-test: echo a msg in shell
//     Docker tag and upload: tag the docker image with the build no of the jenkins pipelineand   and upload it to the ECR repo
//     helm update: helm chart is already created, update the values.yaml file with newly docker image created with the help of YQ docker container
//    helm  lint and package: lint the helm chart and package it and upload it to the ecr repo.
//     helm deploy: update the kubeconfig file for the eks cluster named dev-eks, and region us-east-1, do the helm deploy in the cluster.




pipeline {
    agent { label 'node-one' }

    parameters {
        string(defaultValue: '590183761682.dkr.ecr.us-east-1.amazonaws.com/plivo-application', name: 'ECR_REPO', description: 'ECR Repository')
        string(defaultValue: '590183761682.dkr.ecr.us-east-1.amazonaws.com/plivo-application-helms', name: 'HELM_ECR_REPO', description: 'Helm ECR Repository')
        string(defaultValue: 'dev-eks', name: 'K8S_CLUSTER', description: 'Kubernetes Cluster Name')
        string(defaultValue: 'us-east-1', name: 'AWS_REGION', description: 'AWS Region')
    }

    environment {
        HELM_CHART_PATH = "plivo-webapp"
        gitRepo = ''
        gitBranch = ''
        dockerImageName = ''
        timestamp = ''
        taggedImage = ''    
    }

    stages {
        // stage('Checkout the code') {
        //     steps {
        //         checkout scm
        //     }
        // }

        stage('Build') {
            steps {
                script {
                    gitRepo = env.GIT_URL.tokenize('/')[-1].replaceAll('\\.git', '')
                    gitBranch = env.BRANCH_NAME
                    dockerImageName = "${gitRepo}-${gitBranch}"
                    // Extract the timestamp from BUILD_ID
                    timestamp = currentBuild.startTimeInMillis.toString()

                    // Combine the timestamp with your image name
                    taggedImage = "${dockerImageName}:${dockerImageName}-${timestamp}"

                    sh "docker build --no-cache -t ${taggedImage} ."
                }
            }
        }

        stage('Unit-test') {
            steps {
                sh 'echo "Run your test cases here.."'
            }
        }

        stage('Docker tag and upload') {
            steps {
                script {
                    // Docker tag
                    sh "docker tag ${taggedImage} ${params.ECR_REPO}:${dockerImageName}-${timestamp}"

                    //Docker login
                    sh "aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 590183761682.dkr.ecr.us-east-1.amazonaws.com"
                    // Docker push
                    sh "docker push ${params.ECR_REPO}:${dockerImageName}-${timestamp}"
                }
            }
        }

        stage('Helm update') {
            steps {
                script {
                    // sh 'docker run --rm -v $(pwd):/$(pwd):rw mikefarah/yq:4 eval --inplace \'.image.tag = "${dockerImageName}-${timestamp}"\' $(pwd)/plivo-webapp/values.yaml'
                    sh "docker run --rm -v \$(pwd):/\$(pwd):rw mikefarah/yq:4 eval --inplace '.image.tag = \"${dockerImageName}-${timestamp}\"' \$(pwd)/plivo-webapp/values.yaml"
                }
            }
        }

        stage('Helm lint and package') {
            steps {
                script {
                    sh 'helm lint ${HELM_CHART_PATH}'
                    sh 'helm package ${HELM_CHART_PATH} -d ${HELM_CHART_PATH}/charts'
                }
            }
        }

        stage('Helm deploy') {
            steps {
                script {
                    withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                        sh """
                            aws eks update-kubeconfig --name ${params.K8S_CLUSTER} --region ${params.AWS_REGION}
                            // helm upgrade --install your-release-name ${HELM_CHART_PATH} -f ${HELM_CHART_PATH}/values.yaml
                        """
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                    sh 'rm -rf /home/ec2-user/workspace'
            }
        }
    }
}