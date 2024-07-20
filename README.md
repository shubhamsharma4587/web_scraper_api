# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version:  2.7.3

* You need to install webdriver
```bash
sudo apt install chromium-chromedriver
``` 

* Check webdriver version
```bash
chromedriver --version
``` 

* Start Rails Server: 
```bash
rails s
``` 
* Install Postman

* Hit API
```bash
localhost:3000/api/v1/companies?filters[batch]=W21&filters[industry]=Healthcare&filters[regions]=Canada&filters[tags]=B2B&filters[team_size]=1-500&filters[isHiring]=true&filters[nonprofit]=false&filters[highlight_black]=false&filters[highlight_latinx]=false&filters[highlight_women]=true&n=1
``` 