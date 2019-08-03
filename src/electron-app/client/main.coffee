import 'bootstrap/dist/css/bootstrap.css'
import './styles/main.scss'
import 'typeface-ubuntu'
import '@fortawesome/fontawesome-pro/css/all.css'

# import './scripts/init.coffee'

import ConnectionController from './scripts/connection.coffee'
import MyApp from './scripts/app.coffee'
app = new MyApp

connection = new ConnectionController
app.connection = connection

app.start()
