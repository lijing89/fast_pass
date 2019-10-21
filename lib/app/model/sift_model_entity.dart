

class siftModel {
  String id;
  String title;
  String depth;
  bool isSelected;

  siftModel(this.id, this.title, this.depth,
      {this.isSelected: false});

  siftModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        depth = json['depth'],
        isSelected = false;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'depth': depth,
        'isSelected': isSelected,
      };
}