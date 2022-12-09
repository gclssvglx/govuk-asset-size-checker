# GOV.UK Asset Size Checker

## Local development

### Run LocalStack

```shell
docker-compose up
```

### Deploy to LocalStack

```shell
sls deploy --stage local
```

### Invoke function

```shell
sls invoke -f checker --stage local
```
