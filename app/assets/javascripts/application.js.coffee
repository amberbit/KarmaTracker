#vendor assets
#= require angular
#= require angular-resource
#= require angular-cookies
#= require angular-mobile
#= require angular-route
#= require jquery-2.0.3.min
#= require ui-bootstrap-tpls-0.8.0.min
#= require moment
#= require hook
#= require mousewheel

#our assets
#= require_self
#= require_tree .

window.KarmaTracker = angular.module('KarmaTracker', ['ngCookies', 'ngMobile', 'ngRoute', 'ui.bootstrap', 'ngResource'])
