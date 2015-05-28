This repository contains scripts to merge two ROM-databases together.

### Step 0:

**DO NOT RUN THIS AROUND MIDNIGHT**

### Step 1: Disable application

```
cd deployer
bundle exec cap -f Capfile.roqua lentis-staging maintenance:xoff
bundle exec cap -f Capfile.roqua lentis-staging delayed_job:stop
ssh deploy@stag-rom-util1
echo "off" > /var/www/staging.lentis.roqua.nl/current/config/cron_state
```

### Step 2: Merge the database

```
ssh deploy@stag-rom-util1
cd rom-database-merger
git pull
SOURCE="r_lentis_staging" TARGET="r_rom_staging" ACTUAL=true INCREMENT=9000000 bundle exec ruby merge.rb
```

### Step 3: Update the webserver configs

```
knife data bag edit roqua staging
```

Add `action: 'delete'` to the klant section, so it will be removed from Apache configs on `stag-rom-web*`:

```json
    "lentis": {
      "action": "delete",
      ....
      "lb": {.......}
    },
```

Copy that klant's `lb` section to the `lb` section from the rom klant:

```json
    "lb": {
      "lentis": {
        "pem": "****",
        "lb_ip": "97",
        "dns": [
          "staging.lentis.roqua.nl",
          "www-staging.lentis.roqua.nl",
          "epd-staging.lentis.roqua.nl",
          "admin-staging.lentis.roqua.nl",
          "api-staging.lentis.roqua.nl",
          "test.lentis.roqua.nl",
          "login-staging.lentis.roqua.nl",
          "lentis.rom.roqua-staging.nl"
        ]
      }
    }
```

Run chef on all servers. This should remove the old listener, and add the dns to the new one. Should be working automatically.

```bash
ssh stag-rom-web1
sudo mv /var/www/staging.lentis.roqua.nl /var/www/staging.lentis.roqua.nl.disabled
sudo chef-client

ssh stag-rom-web2
sudo mv /var/www/staging.lentis.roqua.nl /var/www/staging.lentis.roqua.nl.disabled
sudo chef-client

ssh stag-rom-web3
sudo mv /var/www/staging.lentis.roqua.nl /var/www/staging.lentis.roqua.nl.disabled
sudo chef-client

ssh stag-rom-util1
sudo mv /var/www/staging.lentis.roqua.nl /var/www/staging.lentis.roqua.nl.disabled
sudo chef-client
```

### Step 4: Remove configs from deployer

```
cd deployer
git rm apps/roqua/lentis-staging.rb
git commit -m 'Remove lentis-staging (merged to rom)'
git push
```

### Step 5: Scout

Open the [Scout DelayedJob plugin template](https://scoutapp.com/roqua/roles/139301/plugin_templates/294271/trigger_templates). Decrement the alert limits to match the newly decreased number of applications running.
