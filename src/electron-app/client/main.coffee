import 'bootstrap/dist/css/bootstrap.css'
import './styles/main.scss'
import 'typeface-ubuntu'
import '@fortawesome/fontawesome-pro/css/all.css'

import ConnectionController from './scripts/connection.coffee'
import MyApp from './scripts/app.coffee'

app = new MyApp
app.connection = new ConnectionController

app.start()
