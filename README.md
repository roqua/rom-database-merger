This repository contains scripts to merge two ROM-databases together.

### Step 0:

**DO NOT RUN THIS AROUND MIDNIGHT**

### Step 1: Disable application

```
cd deployer
bundle exec cap -f Capfile.roqua research-staging maintenance:xoff
bundle exec cap -f Capfile.roqua research-staging delayed_job:stop
ssh deploy@stag-rom-util1
echo "off" > /var/www/staging.research.roqua.nl/current/config/cron_state
```

### Step 2: Merge the database

```
ssh deploy@stag-rom-util1
cd rom-database-merger
SOURCE="r_research_staging" TARGET="r_rom_staging" ACTUAL=true INCREMENT=2000000 bundle exec ruby merge.rb
```

### Step 3: Update the webserver configs

```
knife data bag edit roqua staging
```

Add `action: 'delete'` to the klant section, so it will be removed from Apache configs on `stag-rom-web*`:

```json
    "research": {
      "action": "delete",
      ....
      "lb": {.......}
    },
```

Copy that klant's `lb` section to the `lb` section from the rom klant:

```json
    "lb": {
      "research": {
        "pem": "****",
        "lb_ip": "97",
        "dns": [
          "staging.research.roqua.nl",
          "www-staging.research.roqua.nl",
          "epd-staging.research.roqua.nl",
          "admin-staging.research.roqua.nl",
          "api-staging.research.roqua.nl",
          "test.research.roqua.nl",
          "login-staging.research.roqua.nl",
          "research.rom.roqua-staging.nl"
        ]
      }
    }
```

Run chef on all servers. This should remove the old listener, and add the dns to the new one. Should be working automatically.

```bash
ssh stag-rom-web1
sudo mv /var/www/staging.research.roqua.nl /var/www/staging.research.roqua.nl.disabled
sudo chef-client

ssh stag-rom-web2
sudo mv /var/www/staging.research.roqua.nl /var/www/staging.research.roqua.nl.disabled
sudo chef-client

ssh stag-rom-web3
sudo mv /var/www/staging.research.roqua.nl /var/www/staging.research.roqua.nl.disabled
sudo chef-client

ssh stag-rom-util1
sudo mv /var/www/staging.research.roqua.nl /var/www/staging.research.roqua.nl.disabled
sudo chef-client
```

### Step 4: Remove configs from deployer

```
cd deployer
git rm apps/roqua/research-staging.rb
git commit -m 'Remove research-staging (merged to rom)'
git push
```

### Step 5: Scout

Open the [Scout DelayedJob plugin template](https://scoutapp.com/roqua/roles/62131/plugin_templates/119651/trigger_templates). Decrement the alert limits to match the newly decreased number of applications running.
