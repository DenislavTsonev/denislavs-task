# Configuring Gitlab runner

There are a few types of Gitlab runner executors, but based on the task description I would look at two particular executors:

- Shell executor, because I think this is the best candidate for the job. So, basically, we need to do the following:
    1. Install the Runner Agent - https://docs.gitlab.com/runner/install/
    2. To register that runner - `sudo gitlab-runner register`
    3. Then configure that runner - in `/etc/gitlab-runner/` (most probably, depending on how the runner is executed as root or not) folder we should create a file called `config.toml` with the following:
        ```bash
        [[runners]]
            name = "HW test runner"
            url = "your Gitlab URL"
            token = "your_registration_token"
            executor = "shell"
        ```
    4. And then to have something similar in the `.gitlab-ci.yml`
        ```bash
        stages:
            - test

        read_serial_data:
            stage: test
            script:
                - apt-get update && apt-get install -y python3 python3-pip
                - pip3 install pyserial
                - python3 get_serial_data.py -f <the name of the file that we want to store data> -p <serial port location> -b 115200
            tags:
                - your_runner_tag
            artifacts:
                paths:
                - <path to the file that we want to store data>
        ```

- Docker executor, because I think this is also a good candidate for the job. So, basically, we need to do the following:
    1. The only differences with the above config are that `config.toml` file, and that we most probably have to add the serial devices in that config `devices = ["/dev/ttys001", "/dev/ttys002"...]` and of course change the executor type:
    ```bash
    [[runners]]
    name = "HW test runner"
    url = "your Gitlab URL"
    token = "your_registration_token"
    executor = "docker"
    [runners.docker]
        privileged = false
        devices = ["/dev/ttys001", "/dev/ttys002"...]
    ```

## Another way to register Gitlab Runner :
```bash
RUNNER_TOKEN=$(curl --silent --request POST --url "https://<your gitlab URL>/api/v4/user/runners"
  --data "runner_type=instance_type"
  --data "description=<your_runner_description>"
  --data "tag_list=<your_comma_separated_job_tags>"
  --header "PRIVATE-TOKEN: <personal_access_token>")
```
Then, install the runner using your preferred method and register the runner
```bash
gitlab-runner register --non-interactive --name="<your runner name>" --url="https://<your gitlab URL>"
  --token="$RUNNER_TOKEN" --request-concurrency="12" --executor="<your executor>"
systemctl restart gitlab-runner
```

## Running docker in Gitlab pipeline

```bash
stages:
  - test

run_container:
  stage: test
  services:
    - docker:dind
  script:
    - docker pull <from your container registry>
    - docker run --rm -v /tmp/my_data:/app your-container-image:latest -f <the name of the file that we want to store data> -p <serial port location> -b 115200
  artifacts:
    paths:
      - /tmp/my_data/serial_data.log
```

> All of the code examples above are pseudo-code examples, except the Python script that I've tested on my machine with an emulated serial port and it seems working :). I've spent some time to get this working - https://docs.gitlab.com/charts/development/kind/ but I spent a lot of time debugging some deployment issues with that chart and decided to not go in that direction, because of the limited time.