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
               mkdir -p \${WORKSPACE}/.temp/gems
               gem install --install-dir \${WORKSPACE}/.temp/gems rubocop -v 0.61.1
               \${WORKSPACE}/.temp/gems/bin/rubocop
            """
         }
      }
   }
}
