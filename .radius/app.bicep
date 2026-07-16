extension radius

param environment string
param application string
@secure()
param password string
@description('The full container image reference to build and push.')
param image string

resource database 'Radius.Data/mySqlDatabases@2025-08-01-preview' = {
  name: 'mysql'
  properties: {
    environment: environment
    application: application
    codeReference: 'docker-compose.yml'
    database: 'petclinic'
    version: '18.4'
    username: 'spring-petclinic_user'
    password: password
  }
}

resource springPetclinicContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'spring-petclinic'
  properties: {
    environment: environment
    application: application
    codeReference: 'docker-compose.yml'
    containers: {
      springpetclinic: {
        image: 'spring-petclinic/spring-petclinic:latest'
        ports: {
          http: {
            containerPort: 3000
            protocol: 'TCP'
          }
        }
      }
    }
  }
}

