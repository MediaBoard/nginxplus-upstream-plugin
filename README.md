# Nginx Plus Upstream Servers

Rundeck node step plugin to drain and restore servers from Nginx Plus upstreams.

Use cases:
- Take servers out of the cluster during publications.
- Put servers back in production after publications.
- Create jobs to take falied nodes out of production.

## Providers

The plugin comes with the following 2 node step providers.

### nginx-plus-upstream-drain-server

Drain servers out from the selected upstream and wait for 0 active connections before proceding.

#### Configs
| Name | Description | Default | Required |
| --- | --- | :---: | :---: |
| `api_url` | Nginx Plus API URL | Empty | Yes |
| `backup_api_url` | Nginx Plus API URL for backup instance | Empty | No |
| `upstream` | Name of the upstream to look for the server | Empty | Yes |
|  `authentication_method` | Nginx Plus API authentication method | none | Yes |
| `username` | Username to authenticate with Nginx Plus API | Empty | No |
| `password` | Password to authenticate with Nginx Plus API | Empty | No |

### nginx-plus-upstream-up-server

Put the servers back in `up` state in the selected upstream.

#### Configs
| Name | Description | Default | Required |
| --- | --- | :---: | :---: |
| `api_url` | Nginx Plus API URL | Empty | Yes |
| `backup_api_url` | Nginx Plus API URL for backup instance | Empty | No |
| `upstream` | Name of the upstream to look for the server | Empty | Yes |
|  `authentication_method` | Nginx Plus API authentication method | none | Yes |
| `username` | Username to authenticate with Nginx Plus API | Empty | No |
| `password` | Password to authenticate with Nginx Plus API | Empty | No |

## Considerations

When using a backup API URL all get server state requests and activity requests are run on the primare API URL only.

## Build and Install

Run the `build.sh` script then move the generated zip file to `$RDECK_BASE/libext` directory.

```
./build.sh
mv build/sre-rundeck-nginxplus-upstream.zip $RDECK_BASE/libext
```
## Troubleshooting

- If you get the folling error: `Cannot run program $RDECK_BASE/libext/cache/sre-rundeck-nginxplus-upstream/*.sh, Permission denied` make sure to give executions permissions to all *.sh files inside mentioned directory.

## Support and contribution

For support and/or contribute, open an issue on this repository or contact `douglas.barahona@me.com`.