import UIKit

final class MessageCell: UITableViewCell {
    static let id = "MessageCell"

    private let bubbleView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 16
        return v
    }()

    private let bodyLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .regular)
        l.numberOfLines = 0
        return l
    }()

    private let dateLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11, weight: .regular)
        l.textColor = .tertiaryLabel
        return l
    }()

    private var leadingConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(bodyLabel)
        bubbleView.addSubview(dateLabel)

        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false

        leadingConstraint = bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12)
        trailingConstraint = bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12)

        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            leadingConstraint,
            trailingConstraint,
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            bubbleView.widthAnchor.constraint(lessThanOrEqualToConstant: 280),

            bodyLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 10),
            bodyLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            bodyLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),

            dateLabel.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: 4),
            dateLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
            dateLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -8),
        ])
    }

    func configure(body: String, date: Date, isOutgoing: Bool) {
        bodyLabel.text = body
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        dateLabel.text = formatter.string(from: date)

        bubbleView.backgroundColor = isOutgoing ? .systemBlue : .secondarySystemBackground
        bodyLabel.textColor = isOutgoing ? .white : .label
        leadingConstraint.priority = isOutgoing ? .defaultLow : .required
        trailingConstraint.priority = isOutgoing ? .required : .defaultLow
    }
}
