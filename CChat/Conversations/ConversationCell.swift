import UIKit

final class ConversationCell: UITableViewCell {
    static let id = "ConversationCell"

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 17, weight: .semibold)
        return l
    }()

    private let previewLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .regular)
        l.textColor = .secondaryLabel
        l.numberOfLines = 2
        return l
    }()

    private let dateLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .regular)
        l.textColor = .tertiaryLabel
        return l
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(previewLabel)
        contentView.addSubview(dateLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        previewLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: dateLabel.leadingAnchor, constant: -8),

            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            previewLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            previewLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            previewLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            previewLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12),
        ])
    }

    func configure(title: String, preview: String, date: Date) {
        titleLabel.text = title
        previewLabel.text = preview.isEmpty ? NSLocalizedString("no_messages", comment: "") : preview
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        dateLabel.text = formatter.localizedString(for: date, relativeTo: Date())
    }
}
