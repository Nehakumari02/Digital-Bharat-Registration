const Map<String, List<String>> indiaStateCityData = {
  "Andaman and Nicobar Islands": ["Port Blair"],
  "Haryana": [
    "Faridabad", "Gurgaon", "Hisar", "Rohtak", "Panipat", "Karnal", "Sonipat", "Yamunanagar", "Panchkula", "Bhiwani", "Bahadurgarh", "Jind", "Sirsa", "Thanesar", "Kaithal", "Palwal", "Rewari", "Hansi", "Narnaul", "Fatehabad", "Gohana", "Tohana", "Narwana", "Mandi Dabwali", "Charkhi Dadri", "Shahbad", "Pehowa", "Samalkha", "Pinjore", "Ladwa", "Sohna", "Safidon", "Taraori", "Mahendragarh", "Ratia", "Rania", "Sarsod"
  ],
  "Tamil Nadu": [
    "Chennai", "Coimbatore", "Madurai", "Tiruchirappalli", "Salem", "Tirunelveli", "Tiruppur", "Ranipet", "Nagercoil", "Thanjavur", "Vellore", "Kancheepuram", "Erode", "Tiruvannamalai", "Pollachi", "Rajapalayam", "Sivakasi", "Pudukkottai", "Neyveli (TS)", "Nagapattinam", "Viluppuram", "Tiruchengode", "Vaniyambadi", "Theni Allinagaram", "Udhagamandalam", "Aruppukkottai", "Paramakudi", "Arakkonam", "Virudhachalam", "Srivilliputhur", "Tindivanam", "Virudhunagar", "Karur", "Valparai", "Sankarankovil", "Tenkasi", "Palani", "Pattukkottai", "Tirupathur", "Ramanathapuram", "Udumalaipettai", "Gobichettipalayam", "Thiruvarur", "Thiruvallur", "Panruti", "Namakkal", "Thirumangalam", "Vikramasingapuram", "Nellikuppam", "Rasipuram", "Tiruttani", "Nandivaram-Guduvancheri", "Periyakulam", "Pernampattu", "Vellakoil", "Sivaganga", "Vadalur", "Rameshwaram", "Tiruvethipuram", "Perambalur", "Usilampatti", "Vedaranyam", "Sathyamangalam", "Puliyankudi", "Nanjikottai", "Thuraiyur", "Sirkali", "Tiruchendur", "Periyasemur", "Sattur", "Vandavasi", "Tharamangalam", "Tirukkoyilur", "Oddanchatram", "Palladam", "Vadakkuvalliyur", "Tirukalukundram", "Uthamapalayam", "Surandai", "Sankari", "Shenkottai", "Vadipatti", "Sholingur", "Tirupathur", "Manachanallur", "Viswanatham", "Polur", "Panagudi", "Uthiramerur", "Thiruthuraipoondi", "Pallapatti", "Ponneri", "Lalgudi", "Natham", "Unnamalaikadai", "P.N.Patti", "Tharangambadi", "Tittakudi", "Pacode", "O' Valley", "Suriyampalayam", "Sholavandan", "Thammampatti", "Namagiripettai", "Peravurani", "Parangipettai", "Pudupattinam", "Pallikonda", "Sivagiri", "Punjaipugalur", "Padmanabhapuram", "Thirupuvanam"
  ],
  "Madhya Pradesh": [
    "Indore", "Bhopal", "Jabalpur", "Gwalior", "Ujjain", "Sagar", "Ratlam", "Satna", "Murwara (Katni)", "Morena", "Singrauli", "Rewa", "Vidisha", "Ganjbasoda", "Shivpuri", "Mandsaur", "Neemuch", "Nagda", "Itarsi", "Sarni", "Sehore", "Mhow Cantonment", "Seoni", "Balaghat", "Ashok Nagar", "Tikamgarh", "Shahdol", "Pithampur", "Alirajpur", "Mandla", "Sheopur", "Shajapur", "Panna", "Raghogarh-Vijaypur", "Sendhwa", "Sidhi", "Pipariya", "Shujalpur", "Sironj", "Pandhurna", "Nowgong", "Mandideep", "Sihora", "Raisen", "Lahar", "Maihar", "Sanawad", "Sabalgarh", "Umaria", "Porsa", "Narsinghgarh", "Malaj Khand", "Sarangpur", "Mundi", "Nepanagar", "Pasan", "Mahidpur", "Seoni-Malwa", "Rehli", "Manawar", "Rahatgarh", "Panagar", "Wara Seoni", "Tarana", "Sausar", "Rajgarh", "Niwari", "Mauganj", "Manasa", "Nainpur", "Prithvipur", "Sohagpur", "Nowrozabad (Khodargama)", "Shamgarh", "Maharajpur", "Multai", "Pali", "Pachore", "Rau", "Mhowgaon", "Vijaypur", "Narsinghgarh"
  ],
  "Jharkhand": [
    "Dhanbad", "Ranchi", "Jamshedpur", "Bokaro Steel City", "Deoghar", "Phusro", "Adityapur", "Hazaribag", "Giridih", "Ramgarh", "Jhumri Tilaiya", "Saunda", "Sahibganj", "Medininagar (Daltonganj)", "Chaibasa", "Chatra", "Gumia", "Dumka", "Madhupur", "Chirkunda", "Pakaur", "Simdega", "Musabani", "Mihijam", "Patratu", "Lohardaga", "Tenu dam-cum-Kathhara"
  ],
  "Mizoram": ["Aizawl", "Lunglei", "Saiha"],
  "Nagaland": ["Dimapur", "Kohima", "Zunheboto", "Tuensang", "Wokha", "Mokokchung"],
  "Himachal Pradesh": ["Shimla", "Mandi", "Solan", "Nahan", "Sundarnagar", "Palampur", "Kullu", "Manali"],
  "Tripura": ["Agartala", "Udaipur", "Dharmanagar", "Pratapgarh", "Kailasahar", "Belonia", "Khowai"],
  "Andhra Pradesh": [
    "Visakhapatnam", "Vijayawada", "Guntur", "Nellore", "Kurnool", "Rajahmundry", "Kakinada", "Tirupati", "Anantapur", "Kadapa", "Vizianagaram", "Eluru", "Ongole", "Nandyal", "Machilipatnam", "Adoni", "Tenali", "Chittoor", "Hindupur", "Proddatur", "Bhimavaram", "Madanapalle", "Guntakal", "Dharmavaram", "Gudivada", "Srikakulam", "Narasaraopet", "Rajampet", "Tadpatri", "Tadepalligudem", "Chilakaluripet", "Yemmiganur", "Kadiri", "Chirala", "Anakapalle", "Kavali", "Palacole", "Sullurpeta", "Tanuku", "Rayachoti", "Srikalahasti", "Bapatla", "Naidupet", "Nagari", "Gudur", "Vinukonda", "Narasapuram", "Nuzvid", "Markapur", "Ponnur", "Kandukur", "Bobbili", "Rayadurg", "Samalkot", "Jaggaiahpet", "Tuni", "Amalapuram", "Bheemunipatnam", "Venkatagiri", "Sattenapalle", "Pithapuram", "Palasa Kasibugga", "Parvathipuram", "Macherla", "Gooty", "Salur", "Mandapeta", "Jammalamadugu", "Peddapuram", "Punganur", "Nidadavole", "Repalle", "Ramachandrapuram", "Kovvur", "Tiruvuru", "Uravakonda", "Narsipatnam", "Yerraguntla", "Pedana", "Puttur", "Renigunta", "Rajam", "Srisailam Project"
  ],
  "Punjab": [
    "Ludhiana", "Patiala", "Amritsar", "Jalandhar", "Bathinda", "Pathankot", "Hoshiarpur", "Batala", "Moga", "Malerkotla", "Khanna", "Mohali", "Barnala", "Firozpur", "Phagwara", "Kapurthala", "Zirakpur", "Kot Kapura", "Faridkot", "Muktsar", "Rajpura", "Sangrur", "Fazilka", "Gurdaspur", "Kharar", "Gobindgarh", "Mansa", "Malout", "Nabha", "Tarn Taran", "Jagraon", "Sunam", "Dhuri", "Firozpur Cantt.", "Sirhind Fatehgarh Sahib", "Rupnagar", "Jalandhar Cantt.", "Samana", "Nawanshahr", "Rampura Phul", "Nangal", "Nakodar", "Zira", "Patti", "Raikot", "Longowal", "Urmar Tanda", "Morinda", "Phillaur", "Pattran", "Qadian", "Sujanpur", "Mukerian", "Talwara"
  ],
  "Chandigarh": ["Chandigarh"],
  "Rajasthan": [
    "Jaipur", "Jodhpur", "Bikaner", "Udaipur", "Ajmer", "Bhilwara", "Alwar", "Bharatpur", "Pali", "Barmer", "Sikar", "Tonk", "Sadulpur", "Sawai Madhopur", "Nagaur", "Makrana", "Sujangarh", "Sardarshahar", "Ladnu", "Ratangarh", "Nokha", "Nimbahera", "Suratgarh", "Rajsamand", "Lachhmangarh", "Rajgarh (Churu)", "Nasirabad", "Nohar", "Phalodi", "Nathdwara", "Pilani", "Merta City", "Sojat", "Neem-Ka-Thana", "Sirohi", "Pratapgarh", "Rawatbhata", "Sangaria", "Lalsot", "Pilibanga", "Pipar City", "Taranagar", "Vijainagar", "Sumerpur", "Sagwara", "Ramganj Mandi", "Lakheri", "Udaipurwati", "Losal", "Sri Madhopur", "Ramngarh", "Rawatsar", "Rajakhera", "Shahpura", "Raisinghnagar", "Malpura", "Nadbai", "Sanchore", "Nagar", "Rajgarh (Alwar)", "Sheoganj", "Sadri", "Todaraisingh", "Todabhim", "Reengus", "Rajaldesar", "Sadulshahar", "Sambhar", "Prantij", "Mount Abu", "Mangrol", "Phulera", "Mandawa", "Pindwara", "Mandalgarh", "Takhatgarh"
  ],
  "Assam": [
    "Guwahati", "Silchar", "Dibrugarh", "Nagaon", "Tinsukia", "Jorhat", "Bongaigaon City", "Dhubri", "Diphu", "North Lakhimpur", "Tezpur", "Karimganj", "Sibsagar", "Goalpara", "Barpeta", "Lanka", "Lumding", "Mankachar", "Nalbari", "Rangia", "Margherita", "Mangaldoi", "Silapathar", "Mariani", "Marigaon"
  ],
  "Odisha": [
    "Bhubaneswar", "Cuttack", "Raurkela", "Brahmapur", "Sambalpur", "Puri", "Baleshwar Town", "Baripada Town", "Bhadrak", "Balangir", "Jharsuguda", "Bargarh", "Paradip", "Bhawanipatna", "Dhenkanal", "Barbil", "Kendujhar", "Sunabeda", "Rayagada", "Jatani", "Byasanagar", "Kendrapara", "Rajagangapur", "Parlakhemundi", "Talcher", "Sundargarh", "Phulabani", "Pattamundai", "Titlagarh", "Nabarangapur", "Soro", "Malkangiri", "Rairangpur", "Tarbha"
  ],
  "Chhattisgarh": [
    "Raipur", "Bhilai Nagar", "Korba", "Bilaspur", "Durg", "Rajnandgaon", "Jagdalpur", "Raigarh", "Ambikapur", "Mahasamund", "Dhamtari", "Chirmiri", "Bhatapara", "Dalli-Rajhara", "Naila Janjgir", "Tilda Newra", "Mungeli", "Manendragarh", "Sakti"
  ],
  "Jammu and Kashmir": ["Srinagar", "Jammu", "Baramula", "Anantnag", "Sopore", "Rajauri", "Punch", "Udhampur"],
  "Karnataka": [
    "Bengaluru", "Hubli-Dharwad", "Belagavi", "Mangaluru", "Davanagere", "Ballari", "Mysore", "Tumkur", "Shivamogga", "Raayachuru", "Robertson Pet", "Kolar", "Mandya", "Udupi", "Chikkamagaluru", "Karwar", "Ranebennuru", "Ramanagaram", "Gokak", "Yadgir", "Rabkavi Banhatti", "Shahabad", "Sirsi", "Sindhnur", "Tiptur", "Arsikere", "Nanjangud", "Sagara", "Sira", "Puttur", "Athni", "Mulbagal", "Surapura", "Siruguppa", "Mudhol", "Sidlaghatta", "Shahpur", "Saundatti-Yellamma", "Wadi", "Manvi", "Nelamangala", "Lakshmeshwar", "Ramdurg", "Nargund", "Tarikere", "Malavalli", "Savanur", "Lingsugur", "Vijayapura", "Sankeshwara", "Madikeri", "Talikota", "Sedam", "Shikaripur", "Mahalingapura", "Mudalagi", "Muddebihal", "Pavagada", "Malur", "Sindhagi", "Sanduru", "Afzalpur", "Maddur", "Madhugiri", "Tekkalakote", "Terdal", "Mudabidri", "Magadi", "Navalgund", "Shiggaon", "Shrirangapattana", "Sindagi", "Sakaleshapura", "Srinivaspur", "Ron", "Mundargi", "Sadalagi", "Piriyapatna", "Adyar"
  ],
  "Manipur": ["Imphal", "Thoubal", "Lilong", "Mayang Imphal"],
  "Kerala": [
    "Thiruvananthapuram", "Kochi", "Kozhikode", "Kollam", "Thrissur", "Palakkad", "Alappuzha", "Malappuram", "Ponnani", "Vatakara", "Kanhangad", "Taliparamba", "Koyilandy", "Neyyattinkara", "Kayamkulam", "Nedumangad", "Kannur", "Tirur", "Kottayam", "Kasaragod", "Kunnamkulam", "Ottappalam", "Thiruvalla", "Thodupuzha", "Chalakudy", "Changanassery", "Punalur", "Nilambur", "Cherthala", "Perinthalmanna", "Mattannur", "Shoranur", "Varkala", "Paravoor", "Pathanamthitta", "Peringathur", "Attingal", "Kodungallur", "Pappinisseri", "Chittur-Thathamangalam", "Muvattupuzha", "Adoor", "Mavelikkara", "Mavoor", "Perumbavoor", "Vaikom", "Palai", "Panniyannur", "Guruvayoor", "Puthuppally", "Panamattom"
  ],
  "Delhi": ["Delhi", "New Delhi"],
  "Dadra and Nagar Haveli": ["Silvassa", "Daman", "Diu"],
  "Puducherry": ["Pondicherry", "Karaikal", "Yanam", "Mahe"],
  "Uttarakhand": [
    "Dehradun", "Hardwar", "Haldwani-cum-Kathgodam", "Srinagar", "Kashipur", "Roorkee", "Rudrapur", "Rishikesh", "Ramnagar", "Pithoragarh", "Manglaur", "Nainital", "Mussoorie", "Tehri", "Pauri", "Nagla", "Sitarganj", "Bageshwar"
  ],
  "Uttar Pradesh": [
    "Kanpur", "Lucknow", "Ghaziabad", "Agra", "Meerut", "Varanasi", "Prayagraj", "Bareilly", "Aligarh", "Moradabad", "Saharanpur", "Gorakhpur", "Noida", "Firozabad", "Loni", "Jhansi", "Muzaffarnagar", "Mathura", "Ayodhya", "Rampur", "Shahjahanpur", "Farrukhabad-cum-Fategarh", "Maunath Bhanjan", "Hapur", "Modinagar", "Bulandshahr", "Etawah", "Amroha", "Vrindavan", "Mirzapur-cum-Vindhyachal", "Orai", "Bahraich", "Sambhal", "Rae Bareli", "Unnao", "Sitapur", "Jaunpur", "Banda", "Pilibhit", "Baraut", "Lakhimpur", "Baheri", "Hardoi", "Mughalsarai", "Fatehpur", "Etah", "Khurja", "Najeebabad", "Azamgarh", "Ghazipur", "Sultanpur", "Basti", "Binojr", "Mubarakpur", "Tanda", "Obra", "Lalitpur", "Sahanswan", "Khatauli", "Behat", "Babrala", "Kairana", "Sahaswan", "Rath", "Sherkot", "Kalpi", "Sahanpur"
  ],
  "Bihar": [
    "Patna", "Gaya", "Bhagalpur", "Muzaffarpur", "Bihar Sharif", "Darbhanga", "Arrah", "Begusarai", "Katihar", "Munger", "Chhapra", "Danapur", "Saharsa", "Sasaram", "Hajipur", "Dehri", "Bettiah", "Motihari", "Bagaha", "Siwan", "Kishanganj", "Jamalpur", "Buxar", "Jehanabad", "Aurangabad", "Lakhisarai", "Nawada", "Jamui", "Araria", "Dumraon", "Madhubani", "Forbesganj", "Samastipur", "Mokameh", "Supaul", "Narkatiaganj", "Bhabua", "Madhepura", "Sheikhpura", "Sultanganj", "Raxaul Bazar", "Ramnagar", "Murliganj", "Patna"
  ],
  "Gujarat": [
    "Ahmedabad", "Surat", "Vadodara", "Rajkot", "Bhavnagar", "Jamnagar", "Junagadh", "Gandhidham", "Nadiad", "Gandhinagar", "Anand", "Morbi", "Mahesana", "Surendranagar dudhrej", "Bharuch", "Vapi", "Navsari", "Veraval", "Porbandar", "Godhra", "Patan", "Kalol", "Botad", "Amreli", "Deesa", "Jetpur", "Valsad", "Viramgam", "Vyara", "Thangadh", "Modasa", "Sidhpur", "Savarkundla", "Kadi", "Visnagar", "Upleta", "Una", "Idar", "Unjha", "Mahuva", "Radhanpur", "Palitana", "Talaja", "Songadh", "Petlad"
  ],
  "Telangana": [
    "Hyderabad", "Warangal", "Nizamabad", "Karimnagar", "Ramagundam", "Khammam", "Mahbubnagar", "Nalgonda", "Adilabad", "Suryapet", "Miryalaguda", "Siddipet", "Jagtial", "Mancherial", "Kothagudem", "Bodhan", "Sangareddy", "Vicarabad", "Wanaparthy", "Kagaznagar", "Gadwal", "Bellampalle", "Bhongir", "Kamareddy", "Nirmal", "Sircilla", "Mandamarri", "Kyathampalle", "Palwancha", "Jangaon", "Koratla", "Tandur", "Narayanpet"
  ],
  "Meghalaya": ["Shillong", "Tura", "Nongstoin"],
  "Maharashtra": [
    "Mumbai", "Pune", "Nagpur", "Thane", "Pimpri-Chinchwad", "Nashik", "Kalyan-Dombivli", "Vasai-Virar", "Aurangabad", "Navi Mumbai", "Solapur", "Mira-Bhayandar", "Bhiwandi", "Amravati", "Nanded-Waghala", "Kolhapur", "Ulhasnagar", "Sangli-Miraj-Kupwad", "Malegaon", "Jalgaon", "Akola", "Latur", "Dhule", "Ahmednagar", "Chandrapur", "Parbhani", "Ichalkaranji", "Jalna", "Ambarnath", "Bhusawal", "Panvel", "Badlapur", "Beed", "Gondia", "Satara", "Barshi", "Yavatmal", "Achalpur", "Osmanabad", "Nandurbar", "Wardha", "Udgir", "Hinganghat", "Karad", "Chiplun", "Ratnagiri"
  ],
  "West Bengal": [
    "Kolkata", "Howrah", "Durgapur", "Asansol", "Siliguri", "Maheshtala", "Rajpur Sonarpur", "Gopalpur", "Bhatpara", "Panihati", "Kamarhati", "Bardhaman", "Kulti", "Bally", "Barasat", "Uluberia", "Naihati", "Bidhan Nagar", "Kharagpur", "English Bazar", "Haldia", "Madhyamgram", "Habra", "Jalpaiguri", "Santipur", "Balurghat", "Medinipur", "Bankura", "Chakdaha", "Basirhat", "Kanchrapara", "Alipurduar", "Purulia", "Jangipur", "Bansberia", "Ranaghat", "Halisahar", "Rishra", "Khardah", "Baharampur", "Shrirampur", "Arambagh"
  ],
  "Goa": ["Marmagao", "Panaji", "Margao", "Mapusa"],
  "Lakshadweep": ["Kavaratti", "Agatti", "Amini", "Minicoy"],
  "Ladakh": ["Leh", "Kargil"]
};
