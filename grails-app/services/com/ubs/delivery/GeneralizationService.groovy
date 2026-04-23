package com.ubs.delivery

import grails.gorm.transactions.Transactional


@Transactional(readOnly = true)
class GeneralizationService {


    String generalizeAge(Integer birthYear) {
        if (!birthYear) return 'Unknown'
        int age = Calendar.getInstance().get(Calendar.YEAR) - birthYear
        if (age < 18)  return '<18'
        if (age <= 24) return '18-24'
        if (age <= 34) return '25-34'
        if (age <= 44) return '35-44'
        if (age <= 54) return '45-54'
        if (age <= 64) return '55-64'
        return '65+'
    }


    String generalizeEmail(String email) {
        if (!email?.trim()) return 'Unknown'
        int atIdx = email.indexOf('@')
        if (atIdx < 0) return 'Unknown'
        return email.substring(atIdx + 1).toLowerCase()
    }

    String generalizeCity(String city) {
        if (!city?.trim()) return 'Unknown'
        Map<String, String> regionMap = [
                'ramallah'    : 'West Bank',
                'nablus'      : 'West Bank',
                'hebron'      : 'West Bank',
                'jenin'       : 'West Bank',
                'jericho'     : 'West Bank',
                'bethlehem'   : 'West Bank',
                'tulkarm'     : 'West Bank',
                'qalqilya'    : 'West Bank',
                'salfit'      : 'West Bank',
                'tubas'       : 'West Bank',
                'jerusalem'   : 'Jerusalem',
                'gaza'        : 'Gaza Strip',
                'rafah'       : 'Gaza Strip',
                'khan yunis'  : 'Gaza Strip',
                'amman'       : 'Jordan',
        ]
        return regionMap[city.trim().toLowerCase()] ?: 'Other'
    }

    String generalizeUsername(String username) {
        if (!username?.trim()) return 'Unknown'
        String u = username.trim()
        if (u.length() <= 2) return u
        return "${u.substring(0, 2)}[${u.length()}]"
    }

    Map<String, Object> buildAnalystView(User user) {
        [
                id           : user.id,
                usernameHint : generalizeUsername(user.username),
                ageRange     : generalizeAge(user.birthYear),
                emailDomain  : generalizeEmail(user.email),
                region       : generalizeCity(user.city),
                role         : user.role,
                enabled      : user.enabled
        ]
    }
}