This repository contains scripts to merge two ROM-databases together.

### Step 0:

**DO NOT RUN THIS AROUND MIDNIGHT**

### Step 1: Disable application

```
cd deployer
bundle exec cap -f Capfile.roqua umcg-staging maintenance:xoff
bundle exec cap -f Capfile.roqua umcg-staging delayed_job:stop
ssh deploy@stag-rom-util1
echo "off" > /var/www/staging.umcg.roqua.nl/current/config/cron_state
```

### Step 2: Merge the database

```
ssh deploy@stag-rom-util1
cd rom-database-merger
git pull
SOURCE="r_umcg_staging" TARGET="r_rom_staging" ACTUAL=true INCREMENT=11000000 bundle exec ruby merge.rb
```

### Step 3: Update the webserver configs

```
knife data bag edit roqua staging
```

Add `action: 'delete'` to the klant section, so it will be removed from Apache configs on `stag-rom-web*`:

```json
    "umcg": {
      "action": "delete",
      ....
      "lb": {.......}
    },
```

Copy that klant's `lb` section to the `lb` section from the rom klant:

```json
    "lb": {
      "umcg": {
        "pem": "****",
        "lb_ip": "97",
        "dns": [
          "staging.umcg.roqua.nl",
          "www-staging.umcg.roqua.nl",
          "epd-staging.umcg.roqua.nl",
          "admin-staging.umcg.roqua.nl",
          "api-staging.umcg.roqua.nl",
          "test.umcg.roqua.nl",
          "login-staging.umcg.roqua.nl",
          "umcg.rom.roqua-staging.nl"
        ]
      }
    }
```

Run chef on all servers. This should remove the old listener, and add the dns to the new one. Should be working automatically.

```bash
ssh stag-rom-web1
sudo mv /var/www/staging.umcg.roqua.nl /var/www/staging.umcg.roqua.nl.disabled
sudo chef-client

ssh stag-rom-web2
sudo mv /var/www/staging.umcg.roqua.nl /var/www/staging.umcg.roqua.nl.disabled
sudo chef-client

ssh stag-rom-web3
sudo mv /var/www/staging.umcg.roqua.nl /var/www/staging.umcg.roqua.nl.disabled
sudo chef-client

ssh stag-rom-util1
sudo mv /var/www/staging.umcg.roqua.nl /var/www/staging.umcg.roqua.nl.disabled
sudo chef-client
```

### Step 4: Remove configs from deployer

```
cd deployer
git rm apps/roqua/umcg-staging.rb
git commit -m 'Remove umcg-staging (merged to rom)'
git push
```

### Step 5: Scout

Open the [Scout DelayedJob plugin template](https://scoutapp.com/roqua/roles/139301/plugin_templates/294271/trigger_templates). Decrement the alert limits to match the newly decreased number of applications running.
