import React from 'react'

// NOTES
// add 'invalid' class to input to give it a red background
// add error text to the errors div and toggle the 'hidden' property
// add the 'disabled' property to inputs that can't be editted if page is static

class SettingsTray extends React.Component {
  constructor (props) {
    super(props)
    this.state = {
      title:        this.props.title,
      description:  this.props.description,
      redirectURL:  this.props.redirectURL,
      path:         this.props.path,
      template:     this.props.template,
      new:          this.props.new,
      isValid:      true
    }

    this.titleChange = this.titleChange.bind(this)
    this.descriptionChange = this.descriptionChange.bind(this)
    this.redirectURLChange = this.redirectURLChange.bind(this)
    this.pathChange = this.pathChange.bind(this)
    this.templateChange = this.templateChange.bind(this)
    this.onSave = this.onSave.bind(this)
  }

  componentWillReceiveProps (nextProps) {
    this.setState({
      title:        this.props.title,
      description:  this.props.description,
      redirectURL:  this.props.redirectURL,
      path:         this.props.path,
      template:     this.props.template,
      new:          this.props.new,
      isValid:      true
    })
  }

  trayTitle () {
    return (this.state.new) ? "Add Page" : "Page Settings"
  }

  titleChange (event) {
    this.setState({title: event.target.value})
  }

  descriptionChange (event) {
    this.setState({description: event.target.value})
  }

  redirectURLChange (event) {
    this.setState({redirectURL: event.target.value})
  }

  pathChange (event) {
    this.setState({path: event.target.value})
  }

  templateChange (event) {
    this.setState({template: event.target.value})
  }

  onSave () {
    this.props.onSubmit(this.state)
  }

  dynamicPage () {
    return (this.state.new || this.state.template)
  }

  prettyTemplateName (name) {
    return (name.charAt(0).toUpperCase() + name.slice(1)).replace(".html", "")
  }

  renderTemplates () {
    return (
      <div className="thesis-field-row">
        <label>
          <span>Template</span>
          <select value={this.state.template} onChange={this.templateChange}>
            {this.props.templates.map((template) => {
              return <li value={template}>{this.prettyTemplateName(template)}</li>
            })}
          </select>
        </label>
      </div>
    )
  }

  renderRedirectURL () {
    return (
      <div className="thesis-field-row">
        <label>
          <span>Redirect URL (leave blank for none)</span>
          <input type="text" value={this.state.redirectURL} onChange={this.redirectURLChange} />
        </label>
      </div>
    )
  }

  render () {
    return (
      <div className="tray-container">
        <div className="tray-wrap">
          <div className="tray-title">
            {this.trayTitle()}
          </div>
          <div className="thesis-field-row">
            <label>
              <span>Page Path</span>
              <input type="text" value={this.state.path} disabled={!this.dynamicPage()} onChange={this.pathChange} />
            </label>
          </div>
          <div className="thesis-field-row">
            <label>
              <span>Page Title</span>
              <input type="text" placeholder="Example Title" value={this.state.title} onChange={this.titleChange} />
            </label>
          </div>
          <div className="thesis-field-row">
            <label>
              <span>Page Description</span>
              <textarea placeholder="Example page description." value={this.state.description} onChange={this.descriptionChange}></textarea>
            </label>
          </div>
          {this.dynamicPage() ? this.renderRedirectURL() : null}
          {this.dynamicPage() ? this.renderTemplates() : null}
          <div className="thesis-field-row errors" hidden={this.state.isValid}>
            {/* Errors go here. Toggle the hidden property depending on error count. */}
          </div>
          <div className="thesis-field-row cta">
            <button className="thesis-tray-cancel" onClick={this.props.onCancel}>
              Cancel
            </button>
            <button className="thesis-tray-save" onClick={this.onSave}>
              Apply
            </button>
          </div>
        </div>
      </div>
    )
  }
}

export default SettingsTray
