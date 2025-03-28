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
               mkdir -p reports
               gem env
               mkdir -p \${WORKSPACE}/.temp/gems
               gem install --no-document --install-dir \${WORKSPACE}/.temp/gems rubocop:1.75.1
               GEM_PATH=\${WORKSPACE}/.temp/gems \${WORKSPACE}/.temp/gems/bin/rubocop --format html -o reports/rubocop/rubocop.html
            """
         }
      }
      stage('flake8') {
         steps {
            sh """
               mkdir -p reports
               pip3 install --upgrade --target=\${WORKSPACE}/.temp/pip -r requirements.txt
               PYTHONPATH=\${WORKSPACE}/.temp/pip \${WORKSPACE}/.temp/pip/bin/flake8 --exclude=.temp/ --format=html --htmldir reports/flake8
            """
         }
      }
   }
   post {
      always {
         publishHTML(target: [
            allowMissing: false,
            alwaysLinkToLastBuild: true,
            keepAll: false,
            reportDir: 'reports',
            reportFiles: 'rubocop/rubocop.html,flake8/index.html',
            reportName: 'Reports'])
      }
   }
}
