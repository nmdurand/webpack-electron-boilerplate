import Marionette from 'backbone.marionette'
import LoginModalView from '../setup/loginModal.coffee'

class WaitingView extends Marionette.View
	className: 'waitingScreen'
	template: require '../../templates/screens/waiting.hbs'


export default WaitingView
