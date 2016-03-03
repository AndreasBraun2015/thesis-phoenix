import React from 'react'
import ReactDOM from 'react-dom'
import AddButton from './components/add_button'
import DeleteButton from './components/delete_button'
import SettingsButton from './components/settings_button'
import CancelButton from './components/cancel_button'
import SaveButton from './components/save_button'
import EditButton from './components/edit_button'
import {Editor, EditorState} from 'draft-js'

class ThesisEditor extends React.Component {
  constructor (props) {
    super(props)
    this.state = {
      editing: false,
      editorState: EditorState.createEmpty()
    }
  }

  editPressed () {
    this.setState({editing: !this.state.editing})
  }

  onPageContentChange(s) {
    console.log("CHANGED!!!")
    console.log(s)
  }

  renderEditorClass () {
    return this.state.editing ? "active" : ""
  }

  contentEditors() {
    return document.querySelectorAll('.thesis-content-html')
  }

  addContentEditors() {
    Array.prototype.forEach.call(this.contentEditors(), (editor, i) => {
      ReactDOM.render(<Editor editorState={ EditorState.createEmpty() } onChange={this.onPageContentChange} />, editor)
    })
  }

  removeContentEditors() {
    Array.prototype.forEach.call(this.contentEditors(), (editor, i) => {
      ReactDOM.unmountComponentAtNode(editor)
    })
  }

  componentDidUpdate () {
    let el = document.querySelector('body')
    if(this.state.editing) {
      el.classList.add('thesis-editing')
      this.addContentEditors()
    } else {
      el.classList.remove('thesis-editing')
      this.removeContentEditors()
    }
  }

  render () {
    return (
      <div id="thesis-editor" className={this.renderEditorClass()}>
        <AddButton />
        <DeleteButton />
        <SettingsButton />
        <CancelButton />
        <SaveButton />
        <EditButton onPress={this.editPressed.bind(this)} />
      </div>
    )
  }
}

ReactDOM.render(<ThesisEditor />, document.querySelector('#thesis-editor-container'))
