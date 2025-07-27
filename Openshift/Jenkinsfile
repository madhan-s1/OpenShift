def JENKINS_NOTIFICATIONS_TO = "madhan038s@gmail.com"

pipeline {
    agent {
        label 'azuresks'
    }

    environment {
        KUBEADMIN_PASSWORD = credentials('aro-vrsunitaro001-kubeadmin-password')
        ENVIRONMENT = 'vrsunitaro001'
        OCP_GITOPS_ADMINS_GROUP = 'G-OCP-NPROD-CLUSTER-ADMINS'
    }

    parameters {
        choice choices: ['validation', 'gitops'], description: 'which script to run', name: 'action'
    }

    options {
        buildDiscarder logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '', numToKeepStr: '10')
        disableConcurrentBuilds()
        skipDefaultCheckout false
        skipStagesAfterUnstable()
        timeout(100)
    }

    stages {
        stage('Initialize') {
            steps {
                checkPipelineSyntax()
                prepare()
            }
        }

        stage('Checkout gitops Common Manifests') {
            steps {
                dir('aro-gitops') {
                    checkout scm: [$class: 'GitSCM', userRemoteConfigs: [[credentialsId: '3518732c-51cc-4091-88dc-1cfeebb8140c', url: 'git@github.voya.net:voya/aro-gitops.git']], branches: [[name: 'master']]], poll: false
                }
            }
        }

        stage('Execute ansible playbook for cluster validation') {
            when {
                expression { params.action == 'validation' }
            }
            steps {
                sh '''
                ansible-playbook aro-gitops/OCP_AUTOMATION/ocp_validation.yml --extra-vars="ocp_validation_environment=${ENVIRONMENT}" --extra-vars="ocp_validation_openshift_admin_password=${KUBEADMIN_PASSWORD}"
                '''
            }
        }

        stage('Execute ansible playbook for gitops config') {
            when {
                expression { params.action == 'gitops' }
            }
            steps {
                sh '''
                cd aro-gitops/
                ansible-playbook OCP_AUTOMATION/ocp_gitops.yml --extra-vars="ocp_gitops_environment=${ENVIRONMENT}" --extra-vars="ocp_gitops_openshift_admin_password=${KUBEADMIN_PASSWORD}" --extra-vars="ocp_gitops_admins_group=${OCP_GITOPS_ADMINS_GROUP}"
                '''
            }
        }

        post {
            always {
                sh 'printenv'
                deleteDir()
            }
        }
    }
}