This repository contains scripts to merge two ROM-databases together.

### Step 0:

**DO NOT RUN THIS AROUND MIDNIGHT**

### Step 1: Disable application

```
cd deployer
bundle exec cap -f Capfile.roqua accare-staging maintenance:xoff
bundle exec cap -f Capfile.roqua accare-staging delayed_job:stop
ssh deploy@stag-rom-util1
echo "off" > /var/www/staging.accare.roqua.nl/current/config/cron_state
```

### Step 2: Merge the database

```
ssh deploy@stag-rom-util1
cd rom-database-merger
SOURCE="r_accare_staging" TARGET="r_rom_staging" ACTUAL=true INCREMENT=3000000 bundle exec ruby merge.rb
```

### Step 3: Update the webserver configs

```
knife data bag edit roqua staging
```

Add `action: 'delete'` to the klant section, so it will be removed from Apache configs on `stag-rom-web*`:

```json
    "accare": {
      "action": "delete",
      ....
      "lb": {.......}
    },
```

Copy that klant's `lb` section to the `lb` section from the rom klant:

```json
    "lb": {
      "accare": {
        "pem": "****",
        "lb_ip": "97",
        "dns": [
          "staging.accare.roqua.nl",
          "www-staging.accare.roqua.nl",
          "epd-staging.accare.roqua.nl",
          "admin-staging.accare.roqua.nl",
          "api-staging.accare.roqua.nl",
          "test.accare.roqua.nl",
          "login-staging.accare.roqua.nl",
          "accare.rom.roqua-staging.nl"
        ]
      }
    }
```

Run chef on all servers. This should remove the old listener, and add the dns to the new one. Should be working automatically.

```bash
ssh stag-rom-web1
sudo mv /var/www/staging.accare.roqua.nl /var/www/staging.accare.roqua.nl.disabled
sudo chef-client

ssh stag-rom-web2
sudo mv /var/www/staging.accare.roqua.nl /var/www/staging.accare.roqua.nl.disabled
sudo chef-client

ssh stag-rom-web3
sudo mv /var/www/staging.accare.roqua.nl /var/www/staging.accare.roqua.nl.disabled
sudo chef-client

ssh stag-rom-util1
sudo mv /var/www/staging.accare.roqua.nl /var/www/staging.accare.roqua.nl.disabled
sudo chef-client
```

### Step 4: Remove configs from deployer

```
cd deployer
git rm apps/roqua/accare-staging.rb
git commit -m 'Remove accare-staging (merged to rom)'
git push
```

### Step 5: Scout

Open the [Scout DelayedJob plugin template](https://scoutapp.com/roqua/roles/62131/plugin_templates/119651/trigger_templates). Decrement the alert limits to match the newly decreased number of applications running.
