This repository contains scripts to merge two ROM-databases together.

### Step 1: Disable application

```
cd deployer
bundle exec cap -f Capfile.roqua demo-staging maintenance:xon
bundle exec cap -f Capfile.roqua demo-staging delayed_job:stop
```

### Step 2: Merge the database

```
ssh deploy@stag-rom-util1
cd rom-database-merger
SOURCE="r_demo_staging" TARGET="r_rom_staging" ACTUAL=true INCREMENT=1000000 bundle exec ruby merge.rb
```

### Step 3: Update the webserver configs

```
knife data bag edit roqua staging
```

Add `action: 'delete'` to the klant section, so it will be removed from Apache configs on `stag-rom-web*`:

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
          "staging.demo.roqua.nl",
          "www-staging.demo.roqua.nl",
          "epd-staging.demo.roqua.nl",
          "admin-staging.demo.roqua.nl",
          "api-staging.demo.roqua.nl",
          "test.demo.roqua.nl",
          "login-staging.demo.roqua.nl",
          "demo.rom.roqua-staging.nl"
        ]
      }
    }
```

Run chef on all servers. This should remove the old listener, and add the dns to the new one. Should be working automatically.

```bash
ssh stag-rom-web1
sudo mv /var/www/staging.demo.roqua.nl /var/www/staging.demo.roqua.nl.disabled
sudo chef-client

ssh stag-rom-web2
sudo mv /var/www/staging.demo.roqua.nl /var/www/staging.demo.roqua.nl.disabled
sudo chef-client

ssh stag-rom-web3
sudo mv /var/www/staging.demo.roqua.nl /var/www/staging.demo.roqua.nl.disabled
sudo chef-client

ssh stag-rom-util1
sudo mv /var/www/staging.demo.roqua.nl /var/www/staging.demo.roqua.nl.disabled
sudo chef-client
```
