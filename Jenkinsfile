pipeline {
   agent any

   stages {
      stage('shellcheck') {
         steps {
            sh """
               bash -c 'shopt -s globstar; shellcheck -e SC2236 -e SC2230 **/*.sh'
            """
         }
      }
      stage('rubocop') {
         steps {
            sh """
               gem env
               mkdir -p \${WORKSPACE}/.temp/gems
               gem install --no-document --install-dir \${WORKSPACE}/.temp/gems rubocop -v 1.6.1
               GEM_PATH=\${WORKSPACE}/.temp/gems \${WORKSPACE}/.temp/gems/bin/rubocop --format html -o reports/rubocop.html
            """
         }
      }
   }
   post {
      always {
         publishHTML(target: [
            allowMissing: false,
            alwaysLinkToLastBuild: false,
            keepAll: false,
            reportDir: 'reports',
            reportFiles: 'rubocop.html',
            reportName: 'Rubocop',
            reportTitles: 'Rubocop_Results'])
      }
   }
}
