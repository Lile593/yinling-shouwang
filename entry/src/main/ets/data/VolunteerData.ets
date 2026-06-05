import { Volunteer, TimeSlot } from '../models/ServiceModels'

function makeSlots(day: number, start: number, end: number): TimeSlot {
  return { dayOfWeek: day, startHour: start, endHour: end }
}

export function getVolunteerPool(): Volunteer[] {
  return [
    {
      id: 'V001', name: '李思涵', age: 20, gender: '女',
      university: '北京师范大学', major: '教育学', grade: '大二',
      description: '性格温和耐心，擅长与老年人沟通。连续两学期获校级优秀志愿者称号，累计服务时长超80小时。曾协助多位老人学会使用智能手机进行视频通话、朋友圈分享等功能。',
      skills: ['智能手机教学', '微信操作指导', '视频通话设置', 'APP下载安装', '手机支付指导'],
      availableTimes: [makeSlots(1, 14, 17), makeSlots(3, 14, 17), makeSlots(5, 14, 17)],
      rating: 4.9, serviceCount: 28,
      certifications: ['优秀志愿者证书', '老年心理沟通培训'],
      avatar: ''
    },
    {
      id: 'V002', name: '王浩然', age: 22, gender: '男',
      university: '北京邮电大学', major: '计算机科学与技术', grade: '大三',
      description: '技术能力强，熟悉各类智能设备和操作系统。曾为社区20余位老人解决手机、平板等设备问题。擅长用通俗易懂的方式解释技术概念，被老人们亲切称为"小王老师"。',
      skills: ['系统操作指导', '打车软件使用', '地图导航教学', '政务APP操作', '手机安全防护'],
      availableTimes: [makeSlots(2, 9, 12), makeSlots(2, 14, 17), makeSlots(4, 9, 12), makeSlots(4, 14, 17)],
      rating: 4.8, serviceCount: 35,
      certifications: ['计算机二级', '志愿服务三星'],
      avatar: ''
    },
    {
      id: 'V003', name: '张雨桐', age: 21, gender: '女',
      university: '北京大学医学部', major: '临床医学', grade: '大三',
      description: '医学专业背景，熟悉医院系统和就诊流程。多次参与社区义诊活动，擅长为老年人提供就医指导和健康咨询。能用方言与老人交流，亲和力强。',
      skills: ['挂号流程指导', '医院导航指引', '检查报告解读', '用药提醒服务', '健康知识科普'],
      availableTimes: [makeSlots(1, 9, 12), makeSlots(3, 9, 12), makeSlots(5, 9, 12), makeSlots(6, 9, 11)],
      rating: 4.7, serviceCount: 22,
      certifications: ['急救培训证书', '健康管理师(在读)'],
      avatar: ''
    },
    {
      id: 'V004', name: '刘伟', age: 23, gender: '男',
      university: '中国社会科学院大学', major: '社会工作', grade: '研一',
      description: '社工专业研究生，研究方向为老年福利政策。熟悉社保、医保等政策法规，已协助50余位老人办理社保认证、医保报销等业务。曾获市级优秀社工志愿者表彰。',
      skills: ['社保政策解读', '医保报销指导', '养老金资格认证', '低保申请协助', '政务APP办理'],
      availableTimes: [makeSlots(1, 14, 18), makeSlots(2, 14, 18), makeSlots(4, 14, 18), makeSlots(5, 9, 12)],
      rating: 4.9, serviceCount: 52,
      certifications: ['社会工作师(初级)', '老年福利政策培训'],
      avatar: ''
    },
    {
      id: 'V005', name: '陈晓萌', age: 20, gender: '女',
      university: '首都师范大学', major: '心理学', grade: '大二',
      description: '心理学专业学生，曾接受系统的心理咨询培训。善于倾听，能有效缓解老人孤独感和焦虑情绪。独创"数字技能心理疏导法"，帮助老人克服对新技术的恐惧心理。',
      skills: ['心理陪伴疏导', '微信功能指导', '照片视频制作', '手机摄影教学', '防诈骗指导'],
      availableTimes: [makeSlots(1, 9, 12), makeSlots(3, 9, 12), makeSlots(5, 9, 12), makeSlots(0, 14, 17)],
      rating: 4.8, serviceCount: 18,
      certifications: ['心理咨询培训证书', '志愿服务先进个人'],
      avatar: ''
    },
    {
      id: 'V006', name: '赵明辉', age: 22, gender: '男',
      university: '北京交通大学', major: '交通工程', grade: '大四',
      description: '交通专业高年级学生，对公共交通系统和各类出行APP了如指掌。曾为社区老人编写《手机出行操作指南》小册子，设计了大字体版出行流程图。',
      skills: ['公交地铁查询', '打车软件教学', '地图导航操作', '出行路线规划', '实时公交查询'],
      availableTimes: [makeSlots(1, 14, 18), makeSlots(3, 14, 18), makeSlots(5, 14, 18), makeSlots(6, 9, 17)],
      rating: 4.7, serviceCount: 25,
      certifications: ['志愿者服务证书', '交通出行指导培训'],
      avatar: ''
    },
    {
      id: 'V007', name: '孙雅文', age: 21, gender: '女',
      university: '中央财经大学', major: '财政学', grade: '大三',
      description: '财经专业背景，对社保、医保政策有深入研究。曾作为志愿者协助社区老人办理退休金领取、医保异地报销等复杂业务。能用通俗语言解释复杂的政策条款。',
      skills: ['医保政策解读', '社保办理指导', '退休金查询', '异地就医备案', '电子社保卡申领'],
      availableTimes: [makeSlots(2, 9, 12), makeSlots(2, 14, 17), makeSlots(4, 9, 12), makeSlots(4, 14, 17)],
      rating: 4.8, serviceCount: 30,
      certifications: ['志愿服务先进团队(成员)', '财经知识科普讲师'],
      avatar: ''
    },
    {
      id: 'V008', name: '周凯', age: 24, gender: '男',
      university: '北京工业大学', major: '软件工程', grade: '研二',
      description: '软件工程研究生，有2年适老化APP开发经验。能深入浅出地讲解智能设备使用原理，尤其擅长解决老年人常遇到的系统设置、软件更新等问题。',
      skills: ['手机系统设置', 'APP安装更新', '数据备份恢复', '智能家居连接', 'WiFi/蓝牙设置'],
      availableTimes: [makeSlots(1, 14, 17), makeSlots(3, 14, 17), makeSlots(5, 14, 17), makeSlots(0, 10, 16)],
      rating: 4.9, serviceCount: 40,
      certifications: ['软件工程师证书', '适老化设计培训'],
      avatar: ''
    },
    {
      id: 'V009', name: '吴佳怡', age: 20, gender: '女',
      university: '北京外国语大学', major: '英语教育', grade: '大二',
      description: '外语专业学生，同时擅长使用各类社交媒体工具。有丰富的老年人教学经验，独创"一步步跟上"教学法，手把手教老人操作每一个步骤，确保每位老人都能学会。',
      skills: ['微信全面教学', '朋友圈发布指导', '群聊创建管理', '小程序使用教学', '电子相册制作'],
      availableTimes: [makeSlots(2, 9, 12), makeSlots(3, 9, 12), makeSlots(5, 9, 12), makeSlots(6, 14, 17)],
      rating: 4.7, serviceCount: 16,
      certifications: ['志愿者培训证书', '老年数字教育讲师'],
      avatar: ''
    },
    {
      id: 'V010', name: '郑健', age: 23, gender: '男',
      university: '北京中医药大学', major: '中医学', grade: '大四',
      description: '中医药专业学生，熟悉医院各类科室和就诊流程，对中西医结合医院尤为熟悉。擅长为老年人提供全面的就医向导服务，包括预约挂号、科室选择、检查流程等一站式指导。',
      skills: ['医院挂号预约', '科室选择建议', '中医养生指导', '检查流程导航', '药品查询服务'],
      availableTimes: [makeSlots(1, 8, 12), makeSlots(3, 8, 12), makeSlots(5, 8, 12), makeSlots(6, 8, 12)],
      rating: 4.8, serviceCount: 27,
      certifications: ['急救员证书', '健康志愿服务证书'],
      avatar: ''
    }
  ]
}
