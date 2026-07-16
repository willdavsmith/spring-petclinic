extension radius

param environment string

@secure()
param postgresPassword string

resource petclinicApp 'Radius.Core/applications@2025-08-01-preview' = {
  name: 'spring-petclinic'
  properties: {
    environment: environment
  }
}

resource postgresDb 'Radius.Data/postgreSqlDatabases@2025-08-01-preview' = {
  name: 'postgres'
  properties: {
    environment: environment
    application: petclinicApp.id
    database: 'petclinic'
    username: 'myadmin'
    password: postgresPassword
  }
}

resource postgresRuntimeSecret 'Radius.Security/secrets@2025-08-01-preview' = {
  name: 'postgres-runtime-secret'
  properties: {
    environment: environment
    application: petclinicApp.id
    data: {
      password: {
        value: postgresPassword
      }
    }
  }
}

resource petclinicContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'spring-petclinic'
  properties: {
    environment: environment
    application: petclinicApp.id
    containers: {
      petclinic: {
        image: 'dsyer/petclinic'
        ports: {
          web: {
            containerPort: 8080
          }
        }
        env: {
          SPRING_PROFILES_ACTIVE: {
            value: 'postgres'
          }
          POSTGRES_URL: {
            value: 'jdbc:postgresql://${postgresDb.properties.host}:${postgresDb.properties.port}/petclinic'
          }
          POSTGRES_USER: {
            value: 'myadmin'
          }
          POSTGRES_PASSWORD: {
            valueFrom: {
              secretKeyRef: {
                secretName: postgresRuntimeSecret.name
                key: 'password'
              }
            }
          }
        }
      }
    }
  }
}
