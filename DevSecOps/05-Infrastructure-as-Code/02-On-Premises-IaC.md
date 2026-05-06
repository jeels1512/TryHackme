# On-Premises IaC

> **Room:** [https://tryhackme.com/room/onpremisesiac](https://tryhackme.com/room/onpremisesiac)
> **Module:** 5 — Infrastructure as Code
> **Difficulty:** Medium

## Overview

Configuration management for **on-prem servers** — Ansible is the focus. You'll learn inventories, playbooks, modules, roles, Ansible Vault for secrets, and how to use Ansible to provision and configure machines securely.

---

## Key Concepts

### Why on-prem IaC?

Even in a cloud-heavy world, plenty of orgs run on-prem servers:
- Banks and regulated industries
- Hardware-bound workloads
- Cost reasons at scale
- Edge / industrial / hybrid environments

For these, **configuration management** tools (Ansible, Puppet, Chef) are the IaC of choice — they configure servers that already exist.

### Why Ansible specifically?

- **Agentless** — only needs SSH (and Python on target)
- **Push model** — control node initiates connections
- **YAML** — readable, gentle learning curve
- **Idempotent** — modules check state before changing
- **Huge module library** — packages, services, files, users, cloud APIs, network gear, etc.

### Ansible architecture

```
┌──────────────┐         SSH        ┌──────────────┐
│ Control Node │ ─────────────────▶ │   Managed    │
│  (Ansible)   │                    │     Node     │
└──────────────┘                    └──────────────┘
       │                                    ▲
       │                                    │
       │            SSH                     │
       └─────────────────────────────────── ┘
                                            
       Inventory                             
       (which hosts)                        Python interpreter
       Playbooks                            (executes modules)
       (what to do)                         No agent needed
```

### Inventory

A list of hosts Ansible can manage.

#### INI format

```ini
# inventory.ini
[web]
web1.example.com
web2.example.com

[db]
db1.example.com ansible_port=2222

[prod:children]
web
db

[prod:vars]
ansible_user=admin
ansible_ssh_private_key_file=~/.ssh/prod.pem
```

#### YAML format

```yaml
all:
  children:
    web:
      hosts:
        web1.example.com:
        web2.example.com:
    db:
      hosts:
        db1.example.com:
          ansible_port: 2222
```

### Playbooks

YAML files describing what to do.

```yaml
# playbook.yml
- name: Configure web servers
  hosts: web
  become: yes              # use sudo
  vars:
    nginx_version: "1.24.*"

  tasks:
    - name: Install nginx
      apt:
        name: nginx
        state: present
        update_cache: yes

    - name: Copy nginx config
      copy:
        src: files/nginx.conf
        dest: /etc/nginx/nginx.conf
        owner: root
        group: root
        mode: '0644'
      notify: Restart nginx

    - name: Ensure nginx is running and enabled
      service:
        name: nginx
        state: started
        enabled: yes

  handlers:
    - name: Restart nginx
      service:
        name: nginx
        state: restarted
```

### Modules

Each task uses a **module** — Ansible's units of work.

| Module | Purpose |
|--------|---------|
| `apt` / `yum` / `dnf` / `package` | Manage packages |
| `service` / `systemd` | Manage services |
| `copy` | Copy files |
| `template` | Copy with Jinja2 templating |
| `file` | Manage file/dir permissions |
| `lineinfile` | Edit specific lines |
| `user` / `group` | Manage users |
| `cron` | Manage cron jobs |
| `shell` / `command` | Run arbitrary commands (use sparingly) |
| `git` | Clone/update repos |
| `ufw` / `firewalld` / `iptables` | Manage firewalls |

### Variables and templates

Variables can come from:
- Playbook `vars`
- Inventory (`group_vars`, `host_vars` directories)
- Command-line `--extra-vars`
- Roles' `defaults/main.yml` and `vars/main.yml`
- Discovered facts (`ansible_facts`)

Use them in templates:
```jinja
# templates/nginx.conf.j2
worker_processes {{ ansible_processor_vcpus }};
server_name {{ inventory_hostname }};
```

### Roles — reusable building blocks

A role is a directory with a standard structure:
```
roles/
└── webserver/
    ├── tasks/main.yml
    ├── handlers/main.yml
    ├── templates/
    ├── files/
    ├── vars/main.yml
    ├── defaults/main.yml
    └── meta/main.yml
```

Use a role:
```yaml
- hosts: web
  roles:
    - webserver
    - { role: monitoring, monitoring_port: 9100 }
```

### Ansible Vault — encrypting secrets

```bash
# Encrypt a file
ansible-vault encrypt secrets.yml

# Edit (decrypts in your editor, re-encrypts on save)
ansible-vault edit secrets.yml

# Decrypt to file
ansible-vault decrypt secrets.yml

# Encrypt a single string
ansible-vault encrypt_string 'super-secret-password' --name 'db_password'
```

Then use in a playbook:
```yaml
vars_files:
  - secrets.yml

tasks:
  - debug:
      msg: "{{ db_password }}"
```

Run with:
```bash
ansible-playbook playbook.yml --ask-vault-pass
# or with a password file
ansible-playbook playbook.yml --vault-password-file ~/.vault_pass
```

### Security best practices

1. **Use SSH keys, not passwords** for managed nodes
2. **Limit `become` (sudo) use** — only when needed
3. **Encrypt secrets with Vault** — never plaintext in YAML
4. **Avoid `shell` / `command`** when a proper module exists (idempotency!)
5. **Pin module/collection versions** (`requirements.yml`)
6. **Lint your playbooks** with `ansible-lint`
7. **Test in a non-prod environment** with `--check` and Molecule
8. **Don't log sensitive output** — `no_log: true` on tasks
9. **Use roles for reuse** — keep things modular
10. **Run scanners** — Checkov supports Ansible

### Common security misconfigurations Ansible can fix

- Default passwords still set
- SSH allowing root login or password auth
- Outdated packages
- Unwanted services running (telnet, FTP, etc.)
- Wide-open firewalls
- World-writable files in /etc
- No fail2ban / no intrusion detection
- Weak file permissions on sensitive files

### Hardening playbook example

```yaml
- name: Basic Linux hardening
  hosts: all
  become: yes
  tasks:
    - name: Disable root SSH login
      lineinfile:
        path: /etc/ssh/sshd_config
        regexp: '^#?PermitRootLogin'
        line: 'PermitRootLogin no'
      notify: Restart sshd

    - name: Disable password authentication
      lineinfile:
        path: /etc/ssh/sshd_config
        regexp: '^#?PasswordAuthentication'
        line: 'PasswordAuthentication no'
      notify: Restart sshd

    - name: Ensure UFW is enabled
      ufw:
        state: enabled
        policy: deny

    - name: Allow SSH through UFW
      ufw:
        rule: allow
        port: '22'
        proto: tcp

    - name: Install fail2ban
      apt:
        name: fail2ban
        state: present

    - name: Enable fail2ban
      service:
        name: fail2ban
        state: started
        enabled: yes

  handlers:
    - name: Restart sshd
      service:
        name: ssh
        state: restarted
```

---

## Commands Cheatsheet

### Setup

```bash
# Install
sudo apt install ansible
# or
pip install ansible

# Check version
ansible --version

# Test connection to all hosts
ansible all -i inventory.ini -m ping
```

### Ad-hoc commands

```bash
# Run a single command on a group
ansible web -i inventory.ini -m shell -a "uptime"

# Install a package on the fly
ansible web -i inventory.ini -m apt -a "name=nginx state=present" --become

# Copy a file
ansible web -i inventory.ini -m copy -a "src=./file dest=/tmp/file" --become

# Get host facts
ansible web -i inventory.ini -m setup
ansible web -i inventory.ini -m setup -a "filter=ansible_distribution*"
```

### Running playbooks

```bash
# Run
ansible-playbook -i inventory.ini playbook.yml

# Dry-run / check mode
ansible-playbook -i inventory.ini playbook.yml --check

# Show diffs
ansible-playbook -i inventory.ini playbook.yml --diff

# Limit to specific hosts
ansible-playbook -i inventory.ini playbook.yml --limit web1.example.com

# Tags
ansible-playbook -i inventory.ini playbook.yml --tags "config,deploy"
ansible-playbook -i inventory.ini playbook.yml --skip-tags "slow"

# Verbosity
ansible-playbook -i inventory.ini playbook.yml -v
ansible-playbook -i inventory.ini playbook.yml -vvv

# Pass variables
ansible-playbook -i inventory.ini playbook.yml --extra-vars "version=1.2"
```

### Vault

```bash
ansible-vault create secret.yml
ansible-vault encrypt secret.yml
ansible-vault edit secret.yml
ansible-vault decrypt secret.yml
ansible-vault rekey secret.yml
ansible-vault encrypt_string 'pass' --name 'db_password'

# Using vault during runs
ansible-playbook playbook.yml --ask-vault-pass
ansible-playbook playbook.yml --vault-password-file ~/.vault_pass
```

### Linting and testing

```bash
# Install
pip install ansible-lint

# Lint a playbook
ansible-lint playbook.yml
ansible-lint roles/

# Syntax check (no execution)
ansible-playbook playbook.yml --syntax-check
```

### Galaxy (community roles & collections)

```bash
# Install a role
ansible-galaxy install geerlingguy.nginx

# Install a collection
ansible-galaxy collection install community.general

# From requirements.yml
ansible-galaxy install -r requirements.yml
```

---

## Room Answers

**Task 1 — Introduction**
- Read through.

**Task 2 — Why Ansible?**
- Q: Is Ansible push or pull?
- A: `Push`
- Q: Does Ansible require an agent on target machines?
- A: `No` (it's agentless)
- Q: What protocol does Ansible use to connect by default?
- A: `SSH`

**Task 3 — Inventory and playbooks**
- Q: What file format do playbooks use?
- A: `YAML`
- Q: What's the file that lists managed hosts called?
- A: `inventory`

**Task 4 — Modules**
- Q: Which module installs packages on Debian/Ubuntu?
- A: `apt`
- Q: Which module manages services?
- A: `service` (or `systemd`)
- Q: Which module copies a file with templating?
- A: `template`

**Task 5 — Vault**
- Q: What's Ansible's tool for encrypting secrets?
- A: `Ansible Vault` (or `ansible-vault`)

**Task 6 — Practical**
- Common task: write or run a playbook against a target.
- Steps:
  1. Edit/check the inventory file (`inventory.ini`)
  2. Run `ansible all -i inventory.ini -m ping` to confirm reachability
  3. Run the provided playbook: `ansible-playbook -i inventory.ini playbook.yml`
  4. Find the flag — usually:
     - In the output of a debug task
     - In a file the playbook creates on the target
     - In `/root/flag.txt` after a hardening playbook completes

```bash
# To check what was created on a target
ssh user@target "cat /root/flag.txt"
# or via Ansible
ansible all -i inventory.ini -m shell -a "cat /root/flag.txt" --become
```

**Task 7 — Conclusion**
- Click to complete.

---

## Key Takeaways

1. **Ansible** = agentless, push, YAML — perfect for on-prem configuration management.
2. **Inventory** = list of hosts. **Playbooks** = what to do. **Modules** = the actions.
3. **Roles** make playbooks reusable and modular.
4. **Ansible Vault** encrypts secrets — never put them in plaintext YAML.
5. Use `--check` and `--diff` for dry-runs, `ansible-lint` for static analysis.
