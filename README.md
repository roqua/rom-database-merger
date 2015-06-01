This repository contains scripts to merge two ROM-databases together.

### Step 0:

**DO NOT RUN THIS AROUND MIDNIGHT**

### Step 1: Disable application

```
cd deployer
bundle exec cap -f Capfile.roqua demo-production maintenance:xoff
bundle exec cap -f Capfile.roqua demo-production delayed_job:stop
ssh deploy@prod-rom-util1
echo "off" > /var/www/production.demo.roqua.nl/current/config/cron_state
```

### Step 2: Merge the database

```
ssh deploy@prod-rom-util1
cd rom-database-merger
git pull
SOURCE="r_demo_produc" TARGET="r_rom_produc" INCREMENT=10000000 bundle exec ruby merge.rb
```

### Step 3: Update the webserver configs

```
knife data bag edit roqua production
```

Add `action: 'delete'` to the klant section, so it will be removed from Apache configs on `prod-rom-web*`:

```json
    "demo": {
      "action": "delete",
      ....
      "lb": {.......}
    },
```

Copy that klant's `lb` section to the `lb` section from the rom klant:

```json
    "lb": {
      "demo": {
        "pem": "****",
        "lb_ip": "97",
        "dns": [
          "production.demo.roqua.nl",
          "www-production.demo.roqua.nl",
          "epd-production.demo.roqua.nl",
          "admin-production.demo.roqua.nl",
          "api-production.demo.roqua.nl",
          "test.demo.roqua.nl",
          "login-production.demo.roqua.nl",
          "demo.rom.roqua-production.nl"
        ]
      }
    }
```

Run chef on all servers. This should remove the old listener, and add the dns to the new one. Should be working automatically.

```bash
ssh prod-rom-web1
sudo mv /var/www/production.demo.roqua.nl /var/www/production.demo.roqua.nl.disabled
sudo chef-client

ssh prod-rom-web2
sudo mv /var/www/production.demo.roqua.nl /var/www/production.demo.roqua.nl.disabled
sudo chef-client

ssh prod-rom-web3
sudo mv /var/www/production.demo.roqua.nl /var/www/production.demo.roqua.nl.disabled
sudo chef-client

ssh prod-rom-util1
sudo mv /var/www/production.demo.roqua.nl /var/www/production.demo.roqua.nl.disabled
sudo chef-client
```

### Step 4: Remove configs from deployer

```
cd deployer
git rm apps/roqua/demo-production.rb
git commit -m 'Remove demo-production (merged to rom)'
git push
```

### Step 5: Scout

Open the [Scout DelayedJob plugin template](https://scoutapp.com/roqua/roles/139301/plugin_templates/294271/trigger_templates). Decrement the alert limits to match the newly decreased number of applications running.
